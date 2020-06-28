import pandas as pd
import numpy as np
import pyarrow as pa
import random
import sys

obj_size = int(sys.argv[2])
data_size = int(sys.argv[1])/obj_size
int_number_in_obj = int((obj_size * 1000 * 1000) / 8)
print('Object size='+str(obj_size)+' MB')
print('Data size='+str(sys.argv[1])+' MB')
# 1000 = 10GB of data, 100 = 1GB of data, 10 = 100MB of data
cols_num = int(data_size)
cols = range(cols_num)
#df = pd.DataFrame(np.random.randint(0,1000000000,size= (1249905,cols_num)), columns=cols)
df = pd.DataFrame(np.random.randint(0,1000000000,size= (int_number_in_obj,cols_num)), columns=cols)
table = pa.Table.from_pandas(df)
batches = table.to_batches()
sink = pa.BufferOutputStream()
writer = pa.RecordBatchStreamWriter(sink, table.schema)

for batch in batches:
    writer.write_batch(batch)
buff = sink.getvalue()
buff = buff.to_pybytes()

f = open('data', 'wb')
f.write(buff)
f.close()

print('The data file with size of ' + str(sys.argv[1]) + ' MB was generated successfully! ')
