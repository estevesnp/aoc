const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.detectLeaks();
    const allocator = gpa.allocator();

    var num_map = try initMap(allocator);
    defer num_map.deinit();

    var count: u64 = 0;

    var iter = std.mem.tokenizeAny(u8, file, "\n");

    while (iter.next()) |line| {
        count += try getNums(allocator, &num_map, line);
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn initMap(allocator: std.mem.Allocator) !std.StringHashMap(u8) {
    var map = std.StringHashMap(u8).init(allocator);

    try map.put("zero", 0);
    try map.put("one", 1);
    try map.put("two", 2);
    try map.put("three", 3);
    try map.put("four", 4);
    try map.put("five", 5);
    try map.put("six", 6);
    try map.put("seven", 7);
    try map.put("eight", 8);
    try map.put("nine", 9);

    return map;
}

fn getNums(
    allocator: std.mem.Allocator,
    num_map: *std.StringHashMap(u8),
    line: []const u8,
) !u8 {
    var index_map = std.AutoHashMap(usize, u8).init(allocator);
    defer index_map.deinit();

    for (line, 0..) |char, idx| {
        if (convertChar(char)) |n| {
            try index_map.put(idx, n);
        }
    }

    var iter = num_map.keyIterator();
    while (iter.next()) |key| {
        var i: usize = 0;
        while (std.mem.indexOfPos(u8, line, i, key.*)) |idx| {
            try index_map.put(idx, num_map.get(key.*).?);
            i += 1;
        }
    }

    var lowest_idx: ?usize = null;
    var highest_idx: ?usize = null;

    var idx_iter = index_map.keyIterator();
    while (idx_iter.next()) |idx| {
        if (lowest_idx == null or idx.* < lowest_idx.?) lowest_idx = idx.*;
        if (highest_idx == null or idx.* > highest_idx.?) highest_idx = idx.*;
    }

    if (lowest_idx == null) @panic("yikes");
    if (highest_idx == null) highest_idx = lowest_idx;

    return index_map.get(lowest_idx.?).? * 10 + index_map.get(highest_idx.?).?;
}

fn convertChar(char: u8) ?u8 {
    if (std.ascii.isDigit(char)) {
        return char - '0';
    }
    return null;
}

test getNums {
    const allocator = std.testing.allocator;
    var num_map = try initMap(allocator);
    defer num_map.deinit();

    try std.testing.expectEqual(11, getNums(allocator, &num_map, "onefiveone"));
}
