# input = "day2-input.txt"
input = "day2-example.txt"

def part1():
    with open(input) as f:
        contents = f.read()
    ranges = contents.split(",")
    ranges = [extents.split("-") for extents in ranges]
    count = 0
    for extents in ranges:
        lower = extents[0].strip()
        upper = extents[1].strip()
        if len(lower) % 2 != 0:
            lower = "1" + "0"*len(lower)
        if int(lower) >= int(upper):
            continue
        order = len(lower)//2
        rep = lower[:order]
        print(f"{lower=}, {upper=}, {rep=}")
        test = rep + rep
        while int(test) <= int(upper):
            if int(test) >= int(lower):
                print(f"{test=}")
                count += int(test)
            rep = str(int(rep) + 1)
            test = rep + rep
        print(count)

def get_factors(n: int):
    factors = set([1])
    for i in range(2, n//2+1):
        if n % i == 0:
            factors.add(i)
    return factors

def count_digits(n: int):
    count = 0
    while n > 0:
        n = n // 10
        count += 1
    return count

def powi(base: int, e: int):
    res = 1
    while e > 0:
        res = res * base
        e -= 1
    return res

def repeat(num: int, n: int):
    res = 0
    n_digits = count_digits(num)
    while n > 0:
        res = res + num*powi(10, (n-1)*n_digits)
        n -= 1
    return res

def part2():
    with open(input) as f:
        contents = f.read()
    ranges = contents.split(",")
    ranges = [extents.split("-") for extents in ranges]
    count = 0
    for extents in ranges:
        lower = int(extents[0].strip())
        upper = int(extents[1].strip())

        print(f"Searching in: {lower=}, {upper=}")
        for order in get_factors(count_digits(lower)):
            print(f"Checking repeats of {order=}")
            divisor = powi(10, count_digits(lower)-order)
            rep = lower // divisor
            test = repeat(rep, count_digits(lower)//order)
            print(f"Starting at {test=}")
            while test <= upper:
                print(f"{rep=}, {order=}, {test=}")
                if test >= lower:
                    print(f">>> {test=}, {divisor=}")
                    count += test
                rep = rep + 1
                # divisor = powi(10, count_digits(rep))
                test = repeat(rep, count_digits(lower)//order)
        print(count)


def main():
    print("PART 1")
    part1()
    print("PART 2")
    part2()


if __name__ == "__main__":
    main()
