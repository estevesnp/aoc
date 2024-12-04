const std = @import("std");
const mem = std.mem;

const XMAS = "XMAS";

const directions = [_][2]i8{
    .{ 1, 1 },
    .{ 1, 0 },
    .{ 1, -1 },
    .{ 0, 1 },
    .{ 0, -1 },
    .{ -1, 1 },
    .{ -1, 0 },
    .{ -1, -1 },
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var matrix = std.ArrayList([]const u8).init(arena.allocator());
    defer matrix.deinit();

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        try matrix.append(line);
    }

    var count: u32 = 0;

    for (matrix.items, 0..) |line, row| {
        for (line, 0..) |char, col| {
            if (char != 'X') continue;
            count += countXmas(matrix.items, row, col);
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn countXmas(matrix: [][]const u8, row: usize, col: usize) u32 {
    const rows = matrix.len;
    const cols = matrix[0].len;

    var count: u32 = 0;

    for (directions) |dir| {
        var cur_row: usize = row;
        var cur_col: usize = col;

        var idx: usize = 1;
        while (idx < XMAS.len) : (idx += 1) {
            const row_check = @as(i32, @intCast(cur_row)) + dir[0];
            const col_check = @as(i32, @intCast(cur_col)) + dir[1];

            if (row_check < 0 or
                row_check >= rows or
                col_check < 0 or
                col_check >= cols or
                matrix[@intCast(row_check)][@intCast(col_check)] != XMAS[idx]) break;

            cur_row = @intCast(row_check);
            cur_col = @intCast(col_check);
        } else count += 1;
    }

    return count;
}
