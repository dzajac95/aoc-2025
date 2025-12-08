input = "day3-input.txt"

def part1():
    with open(input) as f:
        lines = f.readlines()
    sum = 0
    for line in lines:
        line = line.strip()
        digits = [int(c) for c in line]
        max1 = 0
        for i in range(len(digits)-1):
            if digits[i] > digits[max1]:
                max1 = i

        max2 = max1+1
        if max2 >= len(digits):
            max2 = len(digits)-1
        for i in range(max1+1, len(digits)):
            if digits[i] > digits[max2]:
                max2 = i
        value = digits[max1]*10 + digits[max2]
        sum += value
    print(sum)

def part2():
    with open(input) as f:
        lines = f.readlines()
    sum = 0
    N_DIGITS = 12
    for line in lines:
        line = line.strip()
        digits = [int(c) for c in line]
        maxes: list[int] = []
        for n_digits in range(N_DIGITS, 0, -1):
            max_idx = maxes[-1]+1 if len(maxes) > 0 else 0
            end = min(len(digits)-n_digits+1, len(digits))
            for i in range(max_idx, end):
                if digits[i] > digits[max_idx]:
                    max_idx = i
            maxes.append(max_idx)
        value = 0
        for i, m in enumerate(maxes):
            factor = 10**(N_DIGITS-(i+1))
            value += factor * digits[m]
        sum += value
    print(sum)


def main():
    print("=== PART 1 ===")
    part1()

    print()
    print("=== PART 2 ===")
    part2()

if __name__ == "__main__":
    main()
