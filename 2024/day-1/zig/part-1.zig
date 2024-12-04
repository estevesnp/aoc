const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var left_list = ArrayList(u32).init(allocator);
    defer left_list.deinit();

    var right_list = ArrayList(u32).init(allocator);
    defer right_list.deinit();

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        try parseLine(line, &left_list, &right_list);
    }

    std.mem.sort(u32, left_list.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right_list.items, {}, std.sort.asc(u32));

    var sum: u32 = 0;
    for (left_list.items, right_list.items) |left, right| {
        sum += if (left > right) left - right else right - left;
    }

    std.debug.print("RESULT: {}\n", .{sum});
}

fn parseLine(
    line: []const u8,
    left_list: *ArrayList(u32),
    right_list: *ArrayList(u32),
) !void {
    var iter = mem.tokenizeScalar(u8, line, ' ');

    const left = iter.next() orelse @panic("no left found");
    const right = iter.next() orelse @panic("no right found");

    const left_num = parseInt(u32, left, 10) catch @panic("couldnt parse left");
    const right_num = parseInt(u32, right, 10) catch @panic("couldnt parse right");

    try left_list.append(left_num);
    try right_list.append(right_num);
}
