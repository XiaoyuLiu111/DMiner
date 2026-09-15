import argparse
import os
import subprocess
import math
import time
import json
import re
import multiprocessing
import signal
from multiprocessing import (
    Process,
)

def stop_process_group(proc, grace_period=1.0):
    """Stop the task and any child processes it started."""
    if proc.poll() is not None:
        return

    os.killpg(proc.pid, signal.SIGTERM)
    try:
        proc.wait(timeout=grace_period)
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.wait()


def process(infile, timeout):
    start = time.time()
    proc = subprocess.Popen(
        ['./eusolver', infile],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True,
    )
    try:
        stdout, _ = proc.communicate(timeout=timeout)
        prog = stdout.decode('utf-8').replace('\n', '')
        return prog, round(time.time() - start, 4), False
    except subprocess.TimeoutExpired:
        stop_process_group(proc)
        return None, timeout, True

def run(file, parameters, timeout):
    with open(file, 'w') as writer:
        for infile, idx in parameters:
            prog, timecost, _ = process(infile, timeout)
            print(
                json.dumps(
                    {
                        "index": idx,
                        "time": timecost,
                        "program": prog,
                    },
                    ensure_ascii=False,
                ),
                file=writer,
                flush=True,
            )

def divide(lst, partitions):
    chunk_size = math.ceil(len(lst) / partitions)
    for i in range(0, len(lst), chunk_size):
        yield lst[i:i + chunk_size]

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run SyGuS files with a per-file timeout.')
    parser.add_argument('timeout', type=float, help='timeout per input file, in seconds')
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error('timeout must be greater than zero')

    DATA_DIR = os.path.join(os.path.dirname(__file__), 'sl_files')
    OUT_FILE = os.path.join(os.path.dirname(__file__), 'results.out')

    DATA_FILES = sorted(
        (
            os.path.join(DATA_DIR, file_name)
            for file_name in os.listdir(DATA_DIR)
            if file_name.endswith('.sl')
        ),
        key=lambda path: int(re.search(r'\d+', os.path.basename(path)).group()),
    )
    INDICES = [
        int(re.search(r'\d+', os.path.basename(data_file)).group())
        for data_file in DATA_FILES
    ]
    parameters = list(zip(DATA_FILES, INDICES))
    NUM_COUNT = multiprocessing.cpu_count()
    if NUM_COUNT == 1:
        run(OUT_FILE, parameters=parameters, timeout=args.timeout)
    else:
        parameters = list(divide(parameters, NUM_COUNT))
        procs = []
        for worker_idx in range(len(parameters)):
            proc = Process(
                target=run,
                args=(
                    OUT_FILE + str(worker_idx),
                    parameters[worker_idx],
                    args.timeout,
                ),
            )
            proc.start()
            procs.append(proc)

        for proc in procs:
            proc.join()

        with open(OUT_FILE, 'w') as writer:
            results = []
            for worker_idx in range(len(parameters)):
                file = OUT_FILE + str(worker_idx)
                with open(file, 'r') as reader:
                    for line in reader:
                        line = json.loads(line)
                        results.append(line)
                os.remove(file)
            for line in results:
                print(json.dumps(line, ensure_ascii=False), file=writer)
