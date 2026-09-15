import argparse
import os
import subprocess
import math
import time
import json
import re
import multiprocessing
from multiprocessing import (
    Process,
    Queue,
    Manager,
)

def execute(func, args, timeout_seconds):
    manager = Manager()
    queue = manager.Queue()

    queue.empty()

    proc = Process(target=func, args=(args, queue))
    proc.start()

    start = time.time()
    while time.time() - start <= timeout_seconds:
        if not proc.is_alive():
            break
        time.sleep(0.1)
    else:
        proc.terminate()
        proc.join()
        raise TimeoutError(
            f'EUSolver exceeded the {timeout_seconds}-second timeout'
        )

    proc.join()
    if proc.exitcode != 0:
        raise RuntimeError(f'EUSolver worker exited with code {proc.exitcode}')

    try:
        prog, timecost = [queue.get() for _ in range(queue.qsize())]
    except Exception as exc:
        raise RuntimeError('EUSolver worker returned an invalid result') from exc
    return prog, timecost

def process(infile, queue: Queue = None):
    start = time.time()
    result = subprocess.run(
        ['./eusolver', infile],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f'EUSolver failed for {infile} with exit code {result.returncode}: '
            f'{result.stderr.strip()}'
        )
    prog = result.stdout.replace('\n', '')
    if not prog.strip():
        raise RuntimeError(f'EUSolver returned empty output for {infile}')
    timecost = round(time.time() - start, 4)
    if queue is None:
        return prog, timecost
    else:
        queue.put(prog)
        queue.put(timecost)

def run(file, parameters, timeout_seconds):
    with open(file, 'w') as writer:
        for infile, idx in parameters:
            prog, timecost = execute(
                func=process,
                args=infile,
                timeout_seconds=timeout_seconds,
            )
            print(json.dumps({"index": idx, "time": timecost, "program": prog, }, ensure_ascii=False), file=writer)

def divide(lst, partitions):
    chunk_size = math.ceil(len(lst) / partitions)
    for i in range(0, len(lst), chunk_size):
        yield lst[i:i + chunk_size]

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Smoke-test EUSolver with a timeout in seconds.'
    )
    parser.add_argument(
        'timeout_seconds',
        type=float,
        nargs='?',
        default=600,
        help='maximum seconds allowed per benchmark (default: 600)',
    )
    args = parser.parse_args()
    if args.timeout_seconds <= 0:
        parser.error('timeout_seconds must be greater than zero')

    DATA_DIR = os.path.join(os.path.dirname(__file__), 'test_sl_file')
    OUT_FILE = os.path.join(os.path.dirname(__file__), 'test_results.out')

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
        run(
            OUT_FILE,
            parameters=parameters,
            timeout_seconds=args.timeout_seconds,
        )
    else:
        parameters = list(divide(parameters, NUM_COUNT))
        procs = []
        for worker_idx in range(len(parameters)):
            proc = Process(
                target=run,
                args=(
                    OUT_FILE + str(worker_idx),
                    parameters[worker_idx],
                    args.timeout_seconds,
                ),
            )
            proc.start()
            procs.append(proc)

        for proc in procs:
            proc.join()

        failed_workers = [proc.exitcode for proc in procs if proc.exitcode != 0]
        if failed_workers:
            raise RuntimeError(
                f'EUSolver test workers failed with exit codes: {failed_workers}'
            )

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
