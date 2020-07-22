import json
import os
import datetime

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

sns.set(style="whitegrid")
results_dir = './run_query/results'

if __name__ == "__main__":
  with open(os.path.join(results_dir, 'result.json')) as f:
    data = json.loads(f.read())


  client_side = data["lineitem"]["fbx"]
  storage_side = data["lineitem"]["fbx_cls"]


  numpy_array_client_side = []
  numpy_array_storage_side = []


  for key, value in client_side.items():
    points = value.split(",")
    for point in points:
      numpy_array_client_side.append([key, point])


  for key, value in storage_side.items():
    points = value.split(",")
    for point in points:
      numpy_array_storage_side.append([key, point])


  df_client_side = pd.DataFrame(np.array(numpy_array_client_side), columns=['selectivity', 'duration'])
  df_storage_side = pd.DataFrame(np.array(numpy_array_storage_side), columns=['selectivity', 'duration'])

  df_client_side[['duration']] = df_client_side[['duration']].apply(pd.to_numeric) 
  df_storage_side[['duration']] = df_storage_side[['duration']].apply(pd.to_numeric) 

  # plot for client side
  ax = sns.barplot(x="selectivity", y="duration", data=df_client_side)
  ax.figure.savefig("lineitem_fbx_benchmarks_client_side.png", dpi=200)

  # plot for storage side
  ax = sns.barplot(x="selectivity", y="duration", data=df_storage_side)
  ax.figure.savefig("lineitem_fbx_benchmarks_storage_side.png", dpi=200)
