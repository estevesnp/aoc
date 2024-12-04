const std = @import("std");
const mem = std.mem;

const initial_corners = [2][2]i8{ .{ -1, -1 }, .{ -1, 1 } };

const Option = enum(u8) {
    s = 'S',
    m = 'M',
    _,

    fn isValid(self: Option) bool {
        return switch (self) {
            .s, .m => true,
            _ => false,
        };
    }
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
            if (char != 'A') continue;
            if (isXmas(matrix.items, row, col)) count += 1;
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn isXmas(matrix: [][]const u8, row: usize, col: usize) bool {
    const rows = matrix.len;
    const cols = matrix[0].len;

    if (row == 0 or row >= rows - 1 or col == 0 or col >= cols - 1)
        return false;

    inline for (initial_corners) |corner| {
        if (!isValidCornerPair(matrix, row, col, corner[0], corner[1]))
            return false;
    }
    return true;
}

fn isValidCornerPair(matrix: [][]const u8, row: usize, col: usize, rel_row: i32, rel_col: i32) bool {
    const check_row: usize = deriveIndex(row, rel_row);
    const check_col: usize = deriveIndex(col, rel_col);
    const first_corner: Option = @enumFromInt(matrix[check_row][check_col]);

    if (!first_corner.isValid()) return false;

    const check_opp_row: usize = deriveIndex(row, -rel_row);
    const check_opp_col: usize = deriveIndex(col, -rel_col);
    const second_corner: Option = @enumFromInt(matrix[check_opp_row][check_opp_col]);

    if (!second_corner.isValid()) return false;

    return first_corner != second_corner;
}

fn deriveIndex(index: usize, rel_index: i32) usize {
    return @intCast(@as(i32, @intCast(index)) + rel_index);
}
