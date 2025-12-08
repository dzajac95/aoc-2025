input = "day1-input.txt"
# input = "day1-example.txt"

def part1():
    with open(input) as f:
        contents = f.read()

    lines = contents.split("\n")
    moves = []
    count = 50
    password = 0
    for line in lines:
        if line == "":
            break
        dir = line[0]
        amount = int(line[1:])
        amount = amount*-1 if dir == 'L' else amount
        count += amount
        count = count % 100
        if count == 0:
            password += 1
    print(password)

def count_crossings(start, direction, amount):
    crossings = 0
    full_turns = amount // 100
    rem = amount % 100
    if direction == 'L':
        rem *= -1
    crossings += full_turns

    end = start + rem
    if start != 0 and (end <= 0 or end >= 100):
        crossings += 1
    end = end % 100
    return crossings, end

def golf_crossings(start, direction, amount):
    crossings = amount // 100
    rem = amount % 100 * (-1 if direction == 'L' else 1)
    end = start + rem
    if start > 0 and (end <= 0 or end >= 100):
        crossings += 1
    end = end % 100
    return crossings, end

def part2():
    with open(input) as f:
        contents = f.read()

    lines = contents.split("\n")
    count = 50
    password = 0
    print(f"{count=}")
    for line in lines:
        if line == "":
            break
        direction = line[0]
        amount = int(line[1:])
        crossings, count = golf_crossings(count, direction, amount)
        password += crossings
    print(password)

def test_crossings(start, direction, amount):
    crossings, end = count_crossings(start, direction, amount)
    print(f"{start}->{direction}{amount}->{end}, {crossings=}")

def part2_tests():
    test_crossings(0, 'L', 10)
    test_crossings(0, 'R', 10)
    test_crossings(0, 'L', 101)
    test_crossings(0, 'R', 101)
    test_crossings(0, 'L', 550)
    test_crossings(0, 'R', 550)
    test_crossings(0, 'L', 400)
    test_crossings(0, 'R', 400)
    test_crossings(50, 'R', 1000)
    test_crossings(50, 'R', 50)

def main():
    part1()
    part2()
    # part2_tests()


if __name__ == "__main__":
    main()
