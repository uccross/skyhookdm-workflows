import pandas as pd
import numpy as np
import pyarrow as pa
import random
import sys
from skyhookdmdriver.skyhook_common import *
from skyhookdmdriver.skyhook_driver import *

def generate_table():
    f = open('data', 'rb')
    data = f.read()
    batches = []
    reader = pa.ipc.open_stream(data)
    for b in reader:
        batches.append(b)
    table = pa.Table.from_batches(batches)
    return table

def add_metadata(table):

    data_schema = 'test metadata' #generate_data_schema(table)
    meta_obj = TableMeta('0', '1', '2', SkyFormatType.SFT_ARROW, data_schema, 'n/a', 'test table', str(1000))
    sche_meta = meta_obj.getTableMeta()  
    table = table.replace_schema_metadata(sche_meta)
    return table

worker_num = 1

partition_num  = 0

for i in range(worker_num):
    f = open('data', 'rb')
    data = f.read()
    partition_num = int(len(data)/10000000)
    table = generate_table()
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
        print(len(buff_bytes))
        i += 1
