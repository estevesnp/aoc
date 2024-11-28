const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("../inpux.txt", .{});
    defer file.close();
    const reader = file.reader();

    var buff: [1024]u8 = undefined;

    var count: u64 = 0;

    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        count += getNums(line);
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn getNums(line: []u8) u8 {
    var first_digit: ?u8 = null;
    var second_digit: ?u8 = null;

    for (line) |char| {
        if (convertChar(char)) |n| {
            if (first_digit == null) {
                first_digit = n;
                continue;
            }
            second_digit = n;
        }
    }

    if (first_digit == null) @panic("yikes");
    if (second_digit == null) second_digit = first_digit;

    return first_digit.? * 10 + second_digit.?;
}

fn convertChar(char: u8) ?u8 {
    if (char >= '0' and char <= '9') {
        return char - '0';
    }
    return null;
}