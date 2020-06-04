import pandas as pd
import numpy as np
import pyarrow as pa
import random
import sys

data_size = int(sys.argv[1])/10

# 1000 = 10GB of data, 100 = 1GB of data, 10 = 100MB of data
cols_num = int(data_size)
cols = range(cols_num)
df = pd.DataFrame(np.random.randint(0,1000000000,size= (1249905,cols_num)), columns=cols)
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