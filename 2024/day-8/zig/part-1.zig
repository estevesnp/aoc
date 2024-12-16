const std = @import("std");
const mem = std.mem;

const Point = struct { row: isize, col: isize };
const Antenna = struct { freq: u8, point: Point };

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var antenna_map = std.AutoHashMap(u8, std.ArrayList(Point)).init(allocator);
    defer antenna_map.deinit();

    var antinode_set = std.AutoHashMap(Point, void).init(allocator);
    defer antinode_set.deinit();

    var iter = mem.tokenizeScalar(u8, file, '\n');

    var row: usize = 0;
    var col: usize = 0;
    while (iter.next()) |line| : (row += 1) {
        col = line.len;
        try parseLine(allocator, line, row, &antenna_map);
    }

    var antenna_iter = antenna_map.valueIterator();
    while (antenna_iter.next()) |antennas| {
        try parseAntennas(antennas.items, &antinode_set, row, col);
    }

    std.debug.print("RESULT: {}\n", .{antinode_set.count()});
}

fn parseLine(
    allocator: mem.Allocator,
    line: []const u8,
    row: usize,
    antenna_map: *std.AutoHashMap(u8, std.ArrayList(Point)),
) !void {
    for (line, 0..) |char, col| {
        if (char == '.') continue;
        var gop = try antenna_map.getOrPut(char);
        if (!gop.found_existing) {
            gop.value_ptr.* = std.ArrayList(Point).init(allocator);
        }
        try gop.value_ptr.append(.{ .row = @intCast(row), .col = @intCast(col) });
    }
}

fn parseAntennas(
    antennas: []Point,
    antinode_set: *std.AutoHashMap(Point, void),
    rows: usize,
    cols: usize,
) !void {
    if (antennas.len <= 1) return;

    for (0..antennas.len - 1) |i| {
        const point_x = antennas[i];
        for (i + 1..antennas.len) |j| {
            const point_y = antennas[j];

            const vec_row = point_y.row - point_x.row;
            const vec_col = point_y.col - point_x.col;

            const derived_x: Point = .{
                .row = point_x.row - vec_row,
                .col = point_x.col - vec_col,
            };

            if (derived_x.row >= 0 and derived_x.col >= 0 and
                derived_x.row < rows and derived_x.col < cols)
            {
                try antinode_set.put(derived_x, {});
            }

            const derived_y: Point = .{
                .row = point_y.row + vec_row,
                .col = point_y.col + vec_col,
            };

            if (derived_y.row >= 0 and derived_y.col >= 0 and
                derived_y.row < rows and derived_y.col < cols)
            {
                try antinode_set.put(derived_y, {});
            }
        }
    }
}
