const std = @import("std");
const List = std.ArrayList(u32);

pub fn main() !void {
    const file = try std.fs.cwd().openFile("../../input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var left_list = List.init(allocator);
    var right_list = List.init(allocator);

    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
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

fn parseLine(line: []const u8, left_list: *List, right_list: *List) !void {
    var iter = std.mem.tokenizeAny(u8, line, " ");

    const left = iter.next() orelse @panic("no left found");
    const right = iter.next() orelse @panic("no right found");

    const left_num = std.fmt.parseInt(u32, left, 10) catch @panic("couldnt parse left");
    const right_num = std.fmt.parseInt(u32, right, 10) catch @panic("couldnt parse right");

    try left_list.append(left_num);
    try right_list.append(right_num);
}
