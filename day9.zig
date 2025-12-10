const std = @import("std");

const Coord = struct {
    x: i64 = 0,
    y: i64 = 0,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("day9-input.txt", .{});
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();
    var coords = std.ArrayList(Coord){};
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
}
