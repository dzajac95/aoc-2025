const std = @import("std");

const Coord = struct {
    x: i64 = 0,
    y: i64 = 0,

    fn dirTo(self: Coord, other: Coord) Dir {
        const cmp_x = std.math.order(other.x, self.x);
        const cmp_y = std.math.order(other.y, self.y);
        std.debug.assert(cmp_x == .eq or cmp_y == .eq);

        if (self.x == other.x) {
            if (other.y > self.y) {
                return .S;
            } else if (other.y < self.y) {
                return .N;
            }
        }
        if (self.y == other.y) {
            if (other.x > self.x) {
                return .E;
            } else if (other.x < self.x) {
                return .W;
            }
        }
    }
};

const Grid = struct {
    width: u63,
    height: u63,
    data: []u8,

    fn deinit(self: Grid, alloc: std.mem.Allocator) void {
        alloc.free(self.data);
    }

    fn dump(self: Grid) void {
        for (0..self.height) |row| {
            std.debug.print("{s}\n", .{self.data[row*self.width..][0..self.width]});
        }
    }
};

const Dir = enum {
    N,
    E,
    S,
    W,
};

const Winding = enum {
    CW,
    CCW,
};

fn buildGrid(alloc: std.mem.Allocator, coords: []const Coord) !Grid {
    var x_max: u63 = 0;
    var y_max: u63 = 0;
    for (coords) |coord| {
        if (coord.x + 1 > x_max) x_max = @intCast(coord.x + 1);
        if (coord.y + 1 > y_max) y_max = @intCast(coord.y + 1);
    }
    x_max += 1;
    y_max += 1;
    var grid: []u8 = try alloc.alloc(u8, x_max*y_max);
    for (0..grid.len) |i| {
        grid[i] = '.';
    }

    for (coords) |coord| {
        const x: usize = @intCast(coord.x);
        const y: usize = @intCast(coord.y);
        grid[y*x_max + x] = '#';
    }
    return .{
        .width = x_max,
        .height = y_max,
        .data = grid,
    };
}

// fn recIsValid(coords: []const Coord, a: usize, b: usize) bool {

// }

const Context = enum {
    EXAMPLE,
    ACTUAL,
};

const input_file = switch (context) {
    .EXAMPLE => "day9-example.txt",
    .ACTUAL => "day9-input.txt",
};

const context: Context = .EXAMPLE;

pub fn main() !void {
    const file = try std.fs.cwd().openFile(input_file, .{});
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();
    var coords = std.ArrayList(Coord){};
    defer coords.deinit(alloc);
    while (true) {
        const line = reader.interface.takeDelimiterExclusive('\n') catch |e| switch (e) {
            error.EndOfStream => break,
            else => return e,
        };
        reader.interface.toss(1);
        var iter = std.mem.splitScalar(u8, line, ',');
        var c = Coord{};
        c.x = try std.fmt.parseInt(i32, iter.next().?, 10);
        c.y = try std.fmt.parseInt(i32, iter.next().?, 10);
        try coords.append(alloc, c);
    }
    for (coords.items) |coord| {
        std.debug.print("{d} {d}\n", .{coord.x, coord.y});
    }
    var max: usize = 0;
    for (0..coords.items.len) |i| {
        for (i+1..coords.items.len) |j| {
            const a = coords.items[i];
            const b = coords.items[j];
            const area = @abs(a.x - b.x + 1) * @abs(a.y - b.y + 1);
            if (area > max) {
                max = @intCast(area);
            }
        }
    }
    std.debug.print("PART 1: max area = {d}\n", .{max});
    var x_min: usize = std.math.maxInt(usize);
    var y_min: usize = std.math.maxInt(usize);
    var x_max: usize = 0;
    var y_max: usize = 0;
    for (coords.items) |coord| {
        if (coord.x + 1 > x_max) x_max = @intCast(coord.x + 1);
        if (coord.y + 1 > y_max) y_max = @intCast(coord.y + 1);
        if (coord.x < x_min) x_min = @intCast(coord.x);
        if (coord.y < y_min) y_min = @intCast(coord.y);
    }
    std.debug.print("x dim: {d} -> {d}\n", .{x_min, x_max});
    std.debug.print("y dim: {d} -> {d}\n", .{y_min, y_max});
    if (context == .EXAMPLE) {
        var grid = try buildGrid(alloc, coords.items);
        defer grid.deinit(alloc);
        grid.dump();
        for (0..coords.items.len) |i| {
            const cur = coords.items[i];
            const next = coords.items[(i+1)%coords.items.len];
            std.debug.assert(next.x == cur.x or next.y == cur.y);
            const delta_x: i8 = switch (std.math.order(cur.x, next.x)) {
                .lt => 1,
                .eq => 0,
                .gt => -1,
            };
            const delta_y: i8 = switch (std.math.order(cur.y, next.y)) {
                .lt => 1,
                .eq => 0,
                .gt => -1,
            };
            var x: i64 = cur.x + delta_x;
            while (x != next.x) {
                const idx: usize = @intCast(cur.y*grid.width + x);
                grid.data[idx] = 'X';
                x += delta_x;
            }
            var y: i64 = cur.y + delta_y;
            while (y != next.y) {
                const idx: usize = @intCast(y*grid.width + cur.x);
                grid.data[idx] = 'X';
                y += delta_y;
            }
        }
        grid.dump();
    }
}
