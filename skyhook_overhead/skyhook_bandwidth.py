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
        ioctx.close()
        cluster.shutdown()

    except Exception as e:
        return str(e)

    return True


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


def write_to_skyhook(table, obj_prefix = 'S', partition_num = 1000):
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
        write_data(buff_bytes, obj_prefix + str(i), 'test' )
        i += 1


def generate_table():
    f = open('data', 'rb')
    data = f.read()
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


# Read the data from the binary file and construct the Arrow table.

tables = []

partition_num  = 0

for i in range(worker_num):
    f = open('data', 'rb')
    data = f.read()
    partition_num = int(len(data)/10000000)
    table = generate_table()
    tables.append(table)

# partition_num = int(partition_num/10)

# Connect to Ceph cluster and get the ioctx handler.
# ioctx = connect_to_ceph('test')

# Start the timer.
start_time = time.time()

# Create threads according to the number of the workers given in the command line.
processes = []
for i in range(worker_num):
    p = Process(target=write_to_skyhook, args=(tables[i], obj_prefix + 's' + str(i), partition_num))
    processes.append(p)
    p.start()


# Wait for the workers to finish
for p in processes:
    p.join()

# ioctx.aio_flush()
# Get the time when all workers are done.
stop_time = time.time()

# Calculate and print the throughput
#print('write to skyhook bandwidth: ' + str(worker_num * len(data)/1000000/(stop_time - start_time)) + ' MB/s.')
print(str(worker_num * len(data)/1000000/(stop_time - start_time)))
