const std = @import("std");
const mem = std.mem;

const directions = [_][2]isize{
    .{ -1, 0 },
    .{ 1, 0 },
    .{ 0, -1 },
    .{ 0, 1 },
};

const Point = struct { row: usize, col: usize };

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var matrix = std.ArrayList([]const u8).init(allocator);
    defer matrix.deinit();

    var starts = std.ArrayList(Point).init(allocator);
    defer starts.deinit();

    var row: usize = 0;
    var iter = mem.tokenizeScalar(u8, file, '\n');

    while (iter.next()) |line| : (row += 1) {
        try matrix.append(line);
        for (line, 0..) |char, col| {
            if (char == '0') {
                try starts.append(.{ .row = row, .col = col });
            }
        }
    }

    var count: usize = 0;
    for (starts.items) |start| {
        count += findPaths(matrix.items, start);
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn findPaths(matrix: []const []const u8, point: Point) usize {
    var count: usize = 0;
    walk(matrix, &count, '0', point);
    return count;
}

fn walk(
    matrix: []const []const u8,
    count: *usize,
    char: u8,
    point: Point,
) void {
    if (char == '9') {
        count.* += 1;
        return;
    }

    for (directions) |dir| {
        const next_row = @as(isize, @intCast(point.row)) + dir[0];
        const next_col = @as(isize, @intCast(point.col)) + dir[1];

        if (next_row < 0 or next_row >= matrix.len or
            next_col < 0 or next_col >= matrix[0].len)
        {
            continue;
        }

        const next_char = matrix[@intCast(next_row)][@intCast(next_col)];
        if (next_char != char + 1) {
            continue;
        }

        walk(
            matrix,
            count,
            next_char,
            .{ .row = @intCast(next_row), .col = @intCast(next_col) },
        );
    }
}
