const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var map = std.AutoHashMap(u32, u32).init(allocator);
    var right_list = std.ArrayList(u32).init(allocator);

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        try parseLine(line, &map, &right_list);
    }

    var sum: u32 = 0;
    for (right_list.items) |num| {
        sum += num * (map.get(num) orelse 0);
    }

    std.debug.print("RESULT: {}\n", .{sum});
}

fn parseLine(
    line: []const u8,
    map: *std.AutoHashMap(u32, u32),
    right_list: *std.ArrayList(u32),
) !void {
    var iter = mem.tokenizeAny(u8, line, " ");

    const left = iter.next() orelse @panic("no left found");
    const right = iter.next() orelse @panic("no right found");

    const left_num = parseInt(u32, left, 10) catch @panic("couldnt parse left");
    const right_num = parseInt(u32, right, 10) catch @panic("couldnt parse right");

    const count = map.get(left_num) orelse 0;
    try map.put(left_num, count + 1);
    try right_list.append(right_num);
}
