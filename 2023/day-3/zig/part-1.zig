const std = @import("std");
const isDigit = std.ascii.isDigit;

const Point = struct { col: usize, row: usize };

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

    var iter = std.mem.tokenizeAny(u8, file, "\n");
    while (iter.next()) |line| {
        try matrix.append(line);
    }

    const result = getResult(matrix.items);

    std.debug.print("RESULT: {}\n", .{result});
}

fn getResult(matrix: [][]const u8) u32 {
    var count: u32 = 0;
    const cols = matrix[0].len;

    for (matrix, 0..) |line, row| {
        var isValid = false;
        var num: u32 = 0;

        for (line, 0..) |char, col| {
            if (isDigit(char)) {
                num = num * 10 + char - '0';
                isValid = isValid or isAdjacent(matrix, row, col);
            } else {
                num = 0;
                isValid = false;
            }

            if (isValid and (col + 1 == cols or !isDigit(line[col + 1]))) {
                count += num;
            }
        }
    }

    return count;
}

fn isAdjacent(matrix: [][]const u8, row: usize, col: usize) bool {
    const rows = matrix.len;
    const cols = matrix[0].len;
    for (directions) |dir| {
        const rel_row = @as(i32, @intCast(row)) - dir[0];
        const rel_col = @as(i32, @intCast(col)) - dir[1];

        if (rel_row < 0 or rel_row >= rows or rel_col < 0 or rel_col >= cols) continue;

        const rel_row_idx: usize = @intCast(rel_row);
        const rel_col_idx: usize = @intCast(rel_col);

        if (isSymbol(matrix[rel_row_idx][rel_col_idx])) return true;
    }

    return false;
}

fn isSymbol(ch: u8) bool {
    return ch != '.' and !isDigit(ch);
}
