const std = @import("std");

const Pos = struct {
    x: i32,
    y: i32,

    fn add(self: Pos, other: Pos) Pos {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};

const Grid = struct {
    buf: []u8,
    rows: usize,
    cols: usize,
    stride: usize,

    fn get(self: Grid, x: usize, y: usize) ?u8 {
        if (x >= self.cols or y >= self.rows) return null;
        return self.buf[y*self.stride + x];
    }

    fn getPos(self: Grid, pos: Pos) ?u8 {
        const x: usize = @intCast(pos.x);
        const y: usize = @intCast(pos.y);
        return self.get(x, y);
    }

    fn set(self: *Grid, x: usize, y: usize, c: u8) !void {
        if (x >= self.cols or y >= self.rows) return error.OutOfBounds;
        self.buf[y*self.stride + x] =  c;
    }

    fn setPos(self: *Grid, pos: Pos, c: u8) !void {
        const x: usize = @intCast(pos.x);
        const y: usize = @intCast(pos.y);
        return self.set(x, y, c);
    }

    fn dump(self: Grid) void {
        for (0..self.rows) |y| {
            for (0..self.cols) |x| {
                std.debug.print("{c}", .{self.buf[y*self.stride + x]});
            }
            std.debug.print("\n", .{});
        }
    }

};

fn makeGrid(buf: []u8) Grid {
    const stride = std.mem.indexOfScalar(u8, buf, '\n').? + 1;
    const cols = stride - 1;
    const rows = std.mem.count(u8, buf, "\n");
    return .{
        .buf = buf,
        .stride = stride,
        .cols = cols,
        .rows = rows,
    };
}

fn countSplits(grid: Grid, start: usize) usize {
    var beams: [1024]u64 = @splat(0);
    var count: usize = 0;
    beams[start] = 1;
    for (0..grid.rows) |y| {
        for (0..grid.cols) |x| {
            const c = grid.get(x, y);
            if (c == '^' and beams[x] > 0) {
                count += 1;
                if (x > 0) {
                    beams[x-1] = 1;
                }
                if (x < grid.rows-1) {
                    beams[x+1] = 1;
                }
                beams[x] = 0;
            }
        }
    }
    return count;
}

fn countTraversals(grid: Grid, start: usize) usize {
    var beams: [1024]u64 = @splat(0);
    var count: usize = 0;
    beams[start] = 1;
    for (0..grid.rows) |y| {
        for (0..grid.cols) |x| {
            const c = grid.get(x, y);
            if (c == '^' and beams[x] > 0) {
                if (x > 0) {
                    beams[x-1] += beams[x];
                }
                if (x < grid.rows-1) {
                    beams[x+1] += beams[x];
                }
                beams[x] = 0;
            }
        }
    }
    for (beams) |beam| {
        count += beam;
    }
    return count;
}

pub fn main() !void {
    const f = try std.fs.cwd().openFile("day7-example.txt", .{});
    const stat = try f.stat();
    var reader_buf: [4096]u8 = undefined;
    var reader = f.reader(&reader_buf);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const contents = try reader.interface.readAlloc(alloc, stat.size);
    var grid = makeGrid(contents);
    const start_x = blk: {
        for (0..grid.rows) |y| {
            for (0..grid.cols) |x| {
                if (grid.get(x, y) == 'S') {
                    break :blk x;
                }
            }
        }
        break :blk 0;
    };
    std.debug.print("Start pos: {any}\n", .{start_x});
    grid.dump();
    var count = countSplits(grid, start_x);
    std.debug.print("Number of splits: {d}\n", .{count});
    count = countTraversals(grid, start_x);
    // std.debug.print("==========\n", .{});
    // for (0..grid.rows) |y| {
    //     for (0..grid.cols) |x| {
    //         if (grid.visited(x, y)) {
    //             std.debug.print("|", .{});
    //         } else {
    //             std.debug.print("{c}", .{grid.get(x, y).?});
    //         }
    //     }
    //     std.debug.print("\n", .{});
    // }
    std.debug.print("Number of traversals: {d}\n", .{count});
}
