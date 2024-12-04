const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    const file = @embedFile("input.txt");

    var count: u64 = 0;

    var iter = mem.tokenizeSequence(u8, file, "mul(");
    while (iter.next()) |text| {
        const comma = mem.indexOfScalar(u8, text, ',') orelse continue;
        if (comma == text.len - 1) continue;
        const paren = mem.indexOfScalarPos(u8, text, comma + 1, ')') orelse continue;

        const first_num = parseInt(u32, text[0..comma], 10) catch continue;
        const second_num = parseInt(u32, text[comma + 1 .. paren], 10) catch continue;

        count += first_num * second_num;
    }

    std.debug.print("RESULT: {}\n", .{count});
}
