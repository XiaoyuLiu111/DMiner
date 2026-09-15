#!/usr/bin/env python3
import csv


CSV_FILE = "/DMINER_Artifact/experiments/results/mainResults.csv"
TIME_COLUMN = "Total Time"


def main():
    total_times = []

    with open(CSV_FILE, newline="", encoding="utf-8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            value = row.get(TIME_COLUMN)
            if value in (None, ""):
                continue
            total_times.append(float(value))

    if not total_times:
        print(f"No numeric values found in '{TIME_COLUMN}'.")
        return

    average = sum(total_times) / len(total_times)
    print(f"Average Total Time: {average}")


if __name__ == "__main__":
    main()
