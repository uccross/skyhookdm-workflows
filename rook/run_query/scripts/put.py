import os
import sys
import math
import argparse
import subprocess

from concurrent.futures import ThreadPoolExecutor, as_completed


def put(obj_num):
    print(f"Putting object {obj_num}...")
    try:
        subprocess.check_call(
            [
                "rados",
                "-p",
                "tpchdata",
                "put",
                f"public.lineitem.{obj_num}",
                "fbx.lineitem.10MB.75Krows.obj.0",
            ]
        )
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        sys.exit(1)


def put_batch(batch_start, batch_end):
    with ThreadPoolExecutor(max_workers=os.cpu_count()) as executor:
        future_to_put = {
            executor.submit(put, obj_num): obj_num
            for obj_num in range(batch_start, batch_end + 1)
        }
        for future in as_completed(future_to_put):
            url = future_to_put[future]
            try:
                data = future.result()
            except Exception as e:
                print(f"Error: {e}")
                sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Put objects in to Ceph OSDs using multithreading."
    )
    parser.add_argument("--count", help="The number of objects to put.")
    parser.add_argument("--start", default=0, help="The object to start putting from.")
    args = parser.parse_args()

    object_count = int(args.count)
    num_batches = math.ceil(object_count / os.cpu_count())
    start = int(args.start)

    for i in range(num_batches):
        batch_length = os.cpu_count()
        put_batch(start, start + batch_length - 1)
        start += batch_length
