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

    var matrix = std.ArrayList([]u8).init(allocator);
    defer matrix.deinit();

    var plot_score = std.AutoHashMap(u8, usize).init(allocator);
    defer plot_score.deinit();

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        try matrix.append(try allocator.dupe(u8, line));
    }

    for (matrix.items, 0..) |line, row| {
        for (line, 0..) |char, col| {
            if (char == '.') continue;

            const score = try processPlot(
                allocator,
                matrix.items,
                .{ .row = row, .col = col },
                char,
            );

            const gop = try plot_score.getOrPutValue(char, 0);
            gop.value_ptr.* += score;
        }
    }

    var result: usize = 0;

    var plot_iter = plot_score.valueIterator();
    while (plot_iter.next()) |value| {
        result += value.*;
    }

    std.debug.print("RESULT: {}\n", .{result});
}
fn processPlot(
    allocator: mem.Allocator,
    matrix: []const []u8,
    point: Point,
    char: u8,
) !usize {
    var plot = std.AutoHashMap(Point, void).init(allocator);
    defer plot.deinit();

    var perimeter: usize = 0;

    try walk(matrix, &plot, &perimeter, point, char);

    var iter = plot.keyIterator();
    while (iter.next()) |p| {
        matrix[p.row][p.col] = '.';
    }

    return plot.count() * perimeter;
}

fn walk(
    matrix: []const []u8,
    plot: *std.AutoHashMap(Point, void),
    perimeter: *usize,
    point: Point,
    char: u8,
) !void {
    try plot.putNoClobber(point, {});

    for (directions) |dir| {
        const next_row: isize = @as(isize, @intCast(point.row)) + dir[0];
        const next_col: isize = @as(isize, @intCast(point.col)) + dir[1];

        if (next_row < 0 or next_row >= matrix.len or
            next_col < 0 or next_col >= matrix[0].len)
        {
            perimeter.* += 1;
            continue;
        }

        const next_point: Point = .{ .row = @intCast(next_row), .col = @intCast(next_col) };

        if (matrix[next_point.row][next_point.col] != char) {
            perimeter.* += 1;
            continue;
        }

        if (plot.get(next_point) != null) continue;

        try walk(matrix, plot, perimeter, next_point, char);
    }
}
