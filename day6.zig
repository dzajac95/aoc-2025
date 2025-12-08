const std = @import("std");

fn part1(alloc: std.mem.Allocator, contents: []const u8) !void {
    var io = std.Io.Reader.fixed(contents);
    var values = std.ArrayList(u64).empty;
    var first: bool = true;
    var rows: usize = 0;
    var stride: usize = 0;
    while (true) {
        const line = io.takeDelimiterExclusive('\n') catch |e| switch (e) {
            error.EndOfStream => break,
            else => unreachable,
        };
        io.toss(1);
        rows += 1;
        var iter = std.mem.tokenizeScalar(u8, line, ' ');
        while (iter.next()) |field| {
            if (first) {
                stride += 1;
            }
            const x = std.fmt.parseInt(@TypeOf(values.items[0]), field, 10) catch field[0];
            try values.append(alloc, x);
        }
        first = false;
    }
    var total: u64 = 0;
    const ops = values.items[(rows-1)*stride..];
    for (0..stride) |i| {
        const op: u8 = @intCast(ops[i]);
        var value: u64 = switch (op) {
            '+' => 0,
            '*' => 1,
            else => unreachable,
        };
        for (0..rows-1) |row| {
            const x = values.items[row*stride + i];
            switch (op) {
                '+' => value += x,
                '*' => value *= x,
                else => unreachable,
            }
        }
        total += value;
    }
    std.debug.print("PART 1: {d}\n", .{total});
}

const Span = struct {
    start: usize,
    len: usize,
};

const ColumnIterator = struct {
    buf: []const u8,
    delim: u8,
    cur: usize,
    rows: usize,
    stride: usize,
    done: bool,

    fn next(self: *ColumnIterator) ?Span {
        if (self.done) {
            return null;
        }
        var i = self.cur;
        var done: bool = true;
        var all_equal: bool = true;
        while (i < self.stride) {
            done = true;
            all_equal = true;
            for (0..self.rows) |r| {
                const c = self.buf[r*self.stride + i];
                all_equal = all_equal and c == self.delim;
                done = done and c == '\n';
            }
            if (all_equal or done) {
                break;
            }
            i += 1;
        }
        var res: ?Span = null;
        res = Span {
            .start = self.cur,
            .len = i - self.cur,
        };
        self.cur = i + 1;
        self.done = done;
        return res;
    }
};

fn iterColumns(buf: []const u8, delim: u8) ColumnIterator {
    return .{
        .buf = buf,
        .delim = delim,
        .cur = 0,
        .rows = std.mem.count(u8, buf, "\n"),
        .stride = std.mem.indexOfScalar(u8, buf, '\n').? + 1,
        .done = false,
    };
}

fn numAtColumn(buf: []const u8, col: usize, rows: usize, stride: usize) ?u64 {
    var value: u64 = 0;
    var is_num: bool = false;
    var start_row: usize = 0;
    var end_row: usize = rows;

    for (0..rows) |r| {
        const c = buf[r*stride + col];
        if (c == ' ' and is_num) {
            end_row = r;
            break;
        }
        if (c != ' ' and !is_num) {
            is_num = true;
            start_row = r;
        }
    }
    const degree = end_row - start_row - 1;
    for (start_row..end_row) |r| {
        value += (buf[r*stride + col] - '0')*(std.math.powi(u64, 10, degree-(r-start_row)) catch unreachable);
    }
    if (value == 0) return null;
    return value;
}

fn part2(alloc: std.mem.Allocator, contents: []const u8) !void {
    _ = alloc;

    var total: u64 = 0;
    var iter = iterColumns(contents, ' ');
    while (iter.next()) |span| {
        const op = std.mem.trim(u8, contents[(iter.rows-1)*iter.stride + span.start..][0..span.len], " \n");
        std.debug.assert(op.len == 1);
        var value: u64 = switch (op[0]) {
            '*' => 1,
            '+' => 0,
            else => unreachable,
        };
        for (0..span.len) |i| {
            if (numAtColumn(contents, span.start+i, iter.rows-1, iter.stride)) |num| {
                switch (op[0]) {
                    '*' => value *= num,
                    '+' => value += num,
                    else => unreachable,
                }
            }
        }
        total += value;
    }
    std.debug.print("PART 2: {d}\n", .{total});
}

pub fn main() !void {
    const f = try std.fs.cwd().openFile("day6-input.txt", .{});
    const stat = try f.stat();
    var reader_buf: [4096]u8 = undefined;
    var reader = f.reader(&reader_buf);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const contents = try reader.interface.readAlloc(alloc, stat.size);

    std.debug.print("DAY 6\n", .{});
    try part1(alloc, contents);
    try part2(alloc, contents);
}
