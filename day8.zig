const std = @import("std");

const Point = struct {
    x: i64,
    y: i64,
    z: i64,
};

const Junction = struct {
    pos: Point,
    circuit_idx: usize,
};

const Connection = struct {
    a: *Junction,
    b: *Junction,
    distance: f32,
};

const Part = enum {
    part1,
    part2,
};

fn dumpCircuits(circuits: []usize, junctions: []Junction) void {
    for (0..circuits.len) |i| {
        if (circuits[i] > 0) {
            std.debug.print("[{d}] ", .{i});
            for (junctions) |junction| {
                if (junction.circuit_idx == i) {
                    std.debug.print("-> {d} {d} {d} ", .{junction.pos.x, junction.pos.y, junction.pos.z});
                }
            }
            std.debug.print("\n", .{});
        }
    }
}

fn updateConnections(connections: []Connection, circuits: []usize, junctions: []Junction, n: usize) Connection {
    var connection_made: bool = true;
    var last_connection: Connection = connections[0];
    while (connection_made) {
        connection_made = false;
        for (0..n) |i| {
            var c = connections[i];
            if (c.a.circuit_idx != c.b.circuit_idx) {
                if (c.a.circuit_idx > c.b.circuit_idx) {
                    const tmp = c.a;
                    c.a = c.b;
                    c.b = tmp;
                }
                std.debug.print("====================\n", .{});
                var num_rem: usize = 0;
                for (circuits) |circuit_count| {
                    num_rem += @intFromBool(circuit_count > 0);
                }
                if (num_rem < 20) {
                    dumpCircuits(circuits, junctions);
                }
                std.debug.print("Making connection: [{d}] {d} {d} {d} => [{d}] {d} {d} {d}\n", .{ c.a.circuit_idx, c.a.pos.x, c.a.pos.y, c.a.pos.z, c.b.circuit_idx, c.b.pos.x, c.b.pos.y, c.b.pos.z});
                connection_made = true;
                last_connection = c;
                circuits[c.a.circuit_idx] += circuits[c.b.circuit_idx];
                circuits[c.b.circuit_idx] = 0;
                const idx_to_update = c.b.circuit_idx;
                for (junctions) |*junction| {
                    if (junction.circuit_idx == idx_to_update) {
                        junction.circuit_idx = c.a.circuit_idx;
                    }
                }
                if (num_rem < 20) {
                    dumpCircuits(circuits, junctions);
                }
            }
        }
    }
    return last_connection;
}

const part: Part = .part1;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("day8-input.txt", .{});
    defer file.close();
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var points_count: usize = 0;
    while (true) {
        _ = reader.interface.discardDelimiterInclusive('\n') catch |e| switch (e) {
            error.EndOfStream => break,
            else => return e,
        };
        points_count += 1;
    }
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const junctions: []Junction = try alloc.alloc(Junction, points_count);
    const circuits: []usize = try alloc.alloc(usize, points_count);
    var connections = std.array_list.Managed(Connection).init(alloc);
    defer connections.deinit();
    for (0..circuits.len) |i| {
        circuits[i] = 1;
    }

    defer alloc.free(junctions);
    try reader.seekTo(0);
    for (0..junctions.len) |i| {
        var junction = &junctions[i];
        const line = try reader.interface.takeDelimiterExclusive('\n');
        reader.interface.toss(1);
        var iter = std.mem.splitScalar(u8, line, ',');
        junction.pos.x = try std.fmt.parseInt(i64, iter.next().?, 10);
        junction.pos.y = try std.fmt.parseInt(i64, iter.next().?, 10);
        junction.pos.z = try std.fmt.parseInt(i64, iter.next().?, 10);
        junction.circuit_idx = i;
    }
    for (junctions) |junction| {
        std.debug.print("{d} {d} {d}\n", .{junction.pos.x, junction.pos.y, junction.pos.z});
    }
    for (0..junctions.len) |i| {
        for (i+1..junctions.len) |j| {
            const a = junctions[i].pos;
            const b = junctions[j].pos;
            const d: f32 = @floatFromInt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y) + (a.z - b.z)*(a.z - b.z));
            const distance = std.math.sqrt(d);
            try connections.append(.{ .a = &junctions[i], .b = &junctions[j], .distance = distance });
        }
    }
    std.mem.sort(Connection, connections.items, {}, struct {
        fn f(_: void, lhs: Connection, rhs: Connection) bool {
            return lhs.distance < rhs.distance;
        }
    }.f);

    switch (part) {
        .part1 => {
            const NUM_CONNECTIONS = 1000;
            const NUM_HIGHEST_CIRCUITS = 3;
            const end = @min(NUM_CONNECTIONS, connections.items.len);
            _ = updateConnections(connections.items, circuits, junctions, end);

            dumpCircuits(circuits, junctions);
            std.mem.sort(usize, circuits, {}, struct {
                fn f(_: void, lhs: usize, rhs: usize) bool {
                    return rhs < lhs;
                }
            }.f);
            var value: usize = 1;
            for (0..NUM_HIGHEST_CIRCUITS) |i| {
                value *= circuits[i];
            }
            std.debug.print("PART 1: {d}\n", .{value});
        },
        .part2 => {
            const last_connection = updateConnections(connections.items, circuits, junctions, connections.items.len);
            std.debug.print("last connection made:\n", .{});
            std.debug.print("{d} {d} {d}\n", .{last_connection.a.pos.x, last_connection.a.pos.y, last_connection.a.pos.z});
            std.debug.print("{d} {d} {d}\n", .{last_connection.b.pos.x, last_connection.b.pos.y, last_connection.b.pos.z});
            std.debug.print("PART 2: {d}\n", .{last_connection.a.pos.x * last_connection.b.pos.x});
        },
    }

}
