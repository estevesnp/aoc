const std = @import("std");
const isDigit = std.ascii.isDigit;

const Point = struct { col: usize, row: usize };
const NumPoint = struct { point: Point, val: u32 };

const directions = [_][2]i32{
    [_]i32{ 1, 0 },
    [_]i32{ 0, 1 },
    [_]i32{ -1, 0 },
    [_]i32{ 0, -1 },
    [_]i32{ 1, 1 },
    [_]i32{ 1, -1 },
    [_]i32{ -1, 1 },
    [_]i32{ -1, -1 },
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var matrix = std.ArrayList([]const u8).init(allocator);
    defer matrix.deinit();

    var gear_list = std.ArrayList(Point).init(allocator);
    defer gear_list.deinit();

    var iter = std.mem.tokenizeAny(u8, file, "\n");
    var row: usize = 0;
    while (iter.next()) |line| : (row += 1) {
        for (line, 0..) |char, col| {
            if (char == '*') try gear_list.append(.{ .col = col, .row = row });
        }
        try matrix.append(line);
    }

    const result = getResult(matrix.items, gear_list.items);

    std.debug.print("RESULT: {}\n", .{result});
}

fn getResult(
    matrix: [][]const u8,
    gears: []Point,
) u32 {
    var count: u32 = 0;

    for (gears) |gear| {
        if (checkGear(matrix, gear)) |num| count += num;
    }

    return count;
}

fn checkGear(matrix: [][]const u8, gear: Point) ?u32 {
    var num_points: [2]?NumPoint = .{null} ** 2;

    const rows = matrix.len;
    const cols = matrix[0].len;
    for (directions) |dir| {
        const rel_row = @as(i32, @intCast(gear.row)) - dir[0];
        const rel_col = @as(i32, @intCast(gear.col)) - dir[1];

        if (rel_row < 0 or rel_row >= rows or rel_col < 0 or rel_col >= cols) continue;

        const rel_row_idx: usize = @intCast(rel_row);
        const rel_col_idx: usize = @intCast(rel_col);

        if (isDigit(matrix[rel_row_idx][rel_col_idx])) {
            const p = Point{ .col = rel_col_idx, .row = rel_row_idx };
            const num_point = extractNumber(matrix[rel_row_idx], p);
            for (num_points, 0..) |np, idx| {
                if (np == null) {
                    num_points[idx] = num_point;
                    break;
                }

                if (std.meta.eql(np.?, num_point)) break;
            } else return null;
        }
    }

    var count: u32 = 1;
    for (num_points) |np_opt| {
        if (np_opt) |np| count *= np.val else return null;
    }

    return count;
}

fn extractNumber(line: []const u8, point: Point) NumPoint {
    var start: usize = point.col;
    var end: usize = point.col;

    while (start > 0 and isDigit(line[start - 1])) start -= 1;
    while (end < line.len - 1 and isDigit(line[end + 1])) end += 1;

    const num = std.fmt.parseInt(u32, line[start .. end + 1], 10) catch
        std.debug.panic("error parsing number {s}\n", .{line[start .. end + 1]});

    return .{ .point = .{ .col = start, .row = point.row }, .val = num };
}

test checkGear {
    var matrix = [_][]const u8{
        "...123.456...",
        "......*......",
        ".............",
    };
    const gear = Point{ .row = 1, .col = 6 };
    try std.testing.expectEqual(56088, checkGear(&matrix, gear));
}
