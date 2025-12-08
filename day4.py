input = "day4-input.txt"

class Grid:
    def __init__(self, file):
        with open(file) as f:
            contents = f.read()
        self.width = contents.find("\n")
        self.height = contents.count("\n")
        contents = contents.strip("\n")
        self.data = contents.split("\n")

    def adjacent(self, x, y):
        for y_off in (-1, 0, 1):
            for x_off in (-1, 0, 1):
                if x_off == 0 and y_off == 0:
                    continue
                x_idx = x + x_off
                y_idx = y + y_off
                if x_idx < 0 or x_idx >= self.width:
                    continue
                if y_idx < 0 or y_idx >= self.height:
                    continue
                yield x_idx, y_idx

def part1():
    grid = Grid(input)
    count = 0
    accessible = set()
    for y in range(grid.height):
        for x in range(grid.width):
            num_adj = 0
            for x_off, y_off in grid.adjacent(x, y):
                if grid.data[y_off][x_off] == "@":
                    num_adj += 1
            if grid.data[y][x] == "@" and num_adj < 4:
                accessible.add((x, y))
                count += 1
    for y in range(grid.height):
        for x in range(grid.width):
            if (x, y) in accessible:
                print("x", end="")
            else:
                print(grid.data[y][x], end="")
        print()
    print(count)

def part2():
    grid = Grid(input)
    count = 0
    accessible = set()
    while True:
        count_in_round = 0
        for y in range(grid.height):
            for x in range(grid.width):
                num_adj = 0
                for x_off, y_off in grid.adjacent(x, y):
                    if grid.data[y_off][x_off] == "@":
                        num_adj += 1
                if grid.data[y][x] == "@" and num_adj < 4:
                    accessible.add((x, y))
                    grid.data[y] = grid.data[y][:x] + "." + grid.data[y][x+1:]
                    count_in_round += 1
        count += count_in_round
        if count_in_round == 0:
            break
    for y in range(grid.height):
        for x in range(grid.width):
            if (x, y) in accessible:
                print("x", end="")
            else:
                print(grid.data[y][x], end="")
        print()
    print(count)


def main():
    print("=== PART 1 ===")
    part1()

    print()
    print("=== PART 2 ===")
    part2()

if __name__ == "__main__":
    main()
