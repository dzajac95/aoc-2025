input = "day5-input.txt"
from typing import NamedTuple

def part1():
    with open(input) as f:
        lines = [line.strip() for line in f.readlines()]
    sep = 0
    for i, line in enumerate(lines):
        if line == "":
            sep = i
    id_ranges = [(int(l.split('-')[0]), int(l.split('-')[1])) for l in lines[:sep]]
    ids = [int(l) for l in lines[sep+1:]]
    print(id_ranges)
    count = 0
    for id in ids:
        print(id)
        for l, h in id_ranges:
            if l <= id and id <= h:
                count += 1
                break
    print(count)

class IdRange(NamedTuple):
    lo: int
    hi: int

def ranges_overlap(r1: IdRange, r2: IdRange):
    return r1.lo <= r2.hi and r1.hi >= r2.lo

def part2():
    with open(input) as f:
        lines = [line.strip() for line in f.readlines()]
    sep = 0
    for i, line in enumerate(lines):
        if line == "":
            sep = i
    id_ranges = [IdRange(int(l.split('-')[0]), int(l.split('-')[1])) for l in lines[:sep]]
    print(id_ranges)
    while True:
        did_reduce = False
        for i, candidate in enumerate(id_ranges):
            for j, other in enumerate(id_ranges):
                if i == j:
                    continue
                if ranges_overlap(candidate, other):
                    new_range = IdRange(min(candidate.lo, other.lo), max(candidate.hi, other.hi))
                    id_ranges.pop(i)
                    id_ranges.pop(j-1)
                    id_ranges.append(new_range)
                    did_reduce = True
                    break
            if did_reduce:
                break
        if not did_reduce:
            break

    print(id_ranges)
    count = 0
    for id_range in id_ranges:
        count += id_range.hi - id_range.lo + 1
    print(count)

def main():
    print("=== PART 1 ===")
    part1()

    print()
    print("=== PART 2 ===")
    part2()

if __name__ == "__main__":
    main()
