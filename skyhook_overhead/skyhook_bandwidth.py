from skyhookdmdriver.skyhook_common import *
from skyhookdmdriver.skyhook_driver import *
import pyarrow as pa
import time
import rados
import sys
import threading
from multiprocessing import Process


def write_data(buff_bytes, name,  ceph_pool):

    try:
        cluster = rados.Rados(conffile='/etc/ceph/ceph.conf')
        cluster.connect()
        ioctx = cluster.open_ioctx(ceph_pool)
        ioctx.write_full(name, buff_bytes)
        ioctx.set_xattr(name, 'size', bytes(str(len(buff_bytes)),'utf-8'))
        ioctx.close()
        cluster.shutdown()

    except Exception as e:
        return str(e)

    return True

def read_data(name, ceph_pool):
    try:
        cluster = rados.Rados(conffile='/etc/ceph/ceph.conf')
        cluster.connect()
        ioctx = cluster.open_ioctx(ceph_pool)
        size = ioctx.get_xattr(name, "size")
        data = ioctx.read(name, length = int(size))
        ioctx.close()
        cluster.shutdown()
        return data
    except Exception as e:
        return str(e)
    return None

def remove_data(name, ceph_pool):
    try:
        cluster = rados.Rados(conffile='/etc/ceph/ceph.conf')
        cluster.connect()
        ioctx = cluster.open_ioctx(ceph_pool)
        ioctx.remove_object(name)
        ioctx.close()
        cluster.shutdown()
    except Exception as e:
        return str(e)

def write_to_ceph(table,  obj_prefix = 'C', chunk_size = 10000000):
    batches = table.to_batches()
    sink = pa.BufferOutputStream()
    writer = pa.RecordBatchStreamWriter(sink, table.schema)

    for batch in batches:
        writer.write_batch(batch)
    buff = sink.getvalue()
    buff = buff.to_pybytes()

    start = 0
    i = 0
    while(True):
        chunk = buff[start:start + chunk_size]
        write_data(chunk, 'c' + str(i), 'test')

        if(start + chunk_size > len(buff)):
            i += 1
            break

        start += chunk_size
        i += 1

    write_data(buff[start:], obj_prefix + str(i), 'test')


def generate_data_schema(table):
    data_schema = ''
    num = len(table.columns)
    for i in range(20):
        col = table.columns[0]
        ttype = col.type
        name = col._name
        data_schema += '0 4 0 0 ' + name + ';'
    return data_schema


def add_metadata(table):

    data_schema = 'test metadata' #generate_data_schema(table)
    meta_obj = TableMeta('0', '1', '2', SkyFormatType.SFT_ARROW, data_schema, 'n/a', 'test table', str(1000))
    sche_meta = meta_obj.getTableMeta()  
    table = table.replace_schema_metadata(sche_meta)
    return table

def generate_object_name(prefix, worker_index, partition_index):
    return prefix + '_' + str(worker_index) + '_' + str(partition_index)

def write_to_skyhook(table, obj_prefix = 'S', partition_num = 1000, worker_index = 1):
    row_num = len(table.columns[0])
    batches = table.to_batches(row_num/partition_num)
    i = 0 
    for batch in batches:
        sub_table = pa.Table.from_batches([batch])
        sub_table = add_metadata(sub_table)
        batches = sub_table.to_batches()
        sink = pa.BufferOutputStream()
        writer = pa.RecordBatchStreamWriter(sink, table.schema)
        for batch in batches:
            writer.write_batch(batch)
        buff = sink.getvalue()
        buff = buff.to_pybytes()
        buff_bytes = addFB_Meta(buff)
        write_data(buff_bytes, generate_object_name(obj_prefix, worker_index, i), 'test' )
        i += 1


def read_from_skyhook(table, obj_prefix = 'S', partition_num = 1000, worker_index = 1):
    row_num = len(table.columns[0])
    batches = table.to_batches(row_num/partition_num)
    i = 0 
    for batch in batches:
        data = read_data(generate_object_name(obj_prefix, worker_index, i), 'test' )
        i += 1
        
        
def remove_from_skyhook(table, obj_prefix = 'S', partition_num = 1000, worker_index = 1):
    row_num = len(table.columns[0])
    batches = table.to_batches(row_num/partition_num)
    i = 0 
    for batch in batches:
        remove_data(generate_object_name(obj_prefix, worker_index, i), 'test' )
        i += 1
      

def generate_table(data):
    batches = []
    reader = pa.ipc.open_stream(data)
    for b in reader:
        batches.append(b)
    table = pa.Table.from_batches(batches)
    return table


# Get the time when writting data directly to Ceph. 
# ioctx = connect_to_ceph('test')
# table = generate_table()
# start_time = time.time()
# write_to_ceph(table, ioctx = ioctx, obj_prefix = obj_prefix + 'c')
# stop_time = time.time()
# print('write to ceph time: ' + str(stop_time - start_time ))
# time.sleep(30)


# Get the object prefix and the number of the workers from the command line.
obj_prefix = sys.argv[1]
worker_num = int(sys.argv[2])
operation = sys.argv[3]
obj_size = int(sys.argv[4])
obj_size = obj_size * 1000_000
result_path = sys.argv[5]

print("Object Prefix: " + obj_prefix)
print("worker num: "+ sys.argv[2])
print("operation: "+ operation)
print("obj size: "+ sys.argv[4])
print("result_path: "+result_path)

# Read the data from the binary file and construct the Arrow table.
tables = []

partition_num  = 0

for i in range(worker_num):
    f = open('data', 'rb')
    data = f.read()
    partition_num = int(len(data)/obj_size)
    table = generate_table(data)
    tables.append(table)
print("dataframes created")
# partition_num = int(partition_num/10)

# Connect to Ceph cluster and get the ioctx handler.
# ioctx = connect_to_ceph('test')

# Start the timer.
start_time = time.time()
process_target = write_to_skyhook
if operation == 'read':
    process_target = read_from_skyhook
elif operation =='remove':
    process_target = remove_from_skyhook
# Create threads according to the number of the workers given in the command line.
processes = []

    
for i in range(worker_num):
    p = Process(target=process_target, args=(tables[i], obj_prefix, partition_num, i))
    processes.append(p)
    print("process "+str(i)+"started")
    p.start()


# Wait for the workers to finish
for p in processes:
    p.join()

# ioctx.aio_flush()
# Get the time when all workers are done.
stop_time = time.time()

# Calculate and print the throughput
bandwidth = worker_num * len(data)/1000000/(stop_time - start_time)
print('write to skyhook bandwidth: ' + str(bandwidth) + ' MB/s.')
f = open(result_path + "client_"+sys.argv[4]+"_"+str(worker_num)+"_"+operation+"_bandwidth.log", "w")
f.write("%d, %d, %f\r\n" % (obj_size, worker_num, bandwidth))
f.close()
