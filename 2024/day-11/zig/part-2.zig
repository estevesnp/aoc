const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const StoneResult = union(enum) {
    One: usize,
    Two: [2]usize,
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var cache = std.AutoHashMap(usize, StoneResult).init(allocator);
    defer cache.deinit();

    var stone_map = std.AutoHashMap(usize, usize).init(allocator);
    defer stone_map.deinit();

    var iter = mem.tokenizeAny(u8, file, " \n");
    while (iter.next()) |stone| {
        const r = try stone_map.getOrPutValue(try fmt.parseInt(usize, stone, 10), 0);
        r.value_ptr.* += 1;
    }

    for (0..75) |_| {
        try blink(allocator, &cache, &stone_map);
    }

    var count: usize = 0;
    var stone_iter = stone_map.valueIterator();
    while (stone_iter.next()) |s| {
        count += s.*;
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn blink(
    allocator: mem.Allocator,
    cache: *std.AutoHashMap(usize, StoneResult),
    stone_map: *std.AutoHashMap(usize, usize),
) !void {
    var new_stones = std.AutoHashMap(usize, usize).init(allocator);

    var iter = stone_map.iterator();
    while (iter.next()) |entry| {
        const stone = entry.key_ptr.*;
        const times = entry.value_ptr.*;

        const gop = try cache.getOrPut(stone);
        if (!gop.found_existing) {
            gop.value_ptr.* = calculateStones(stone);
        }

        switch (gop.value_ptr.*) {
            .One => |s| {
                const r = try new_stones.getOrPutValue(s, 0);
                r.value_ptr.* += times;
            },
            .Two => |stones| {
                for (stones) |s| {
                    const r = try new_stones.getOrPutValue(s, 0);
                    r.value_ptr.* += times;
                }
            },
        }
    }

    stone_map.deinit();
    stone_map.* = new_stones;
}

fn calculateStones(stone: usize) StoneResult {
    if (stone == 0) return .{ .One = 1 };

    const num_of_digits = std.math.log10(stone) + 1;
    if (num_of_digits & 1 == 0) {
        return .{
            .Two = .{
                stone / std.math.pow(usize, 10, num_of_digits / 2),
                stone % std.math.pow(usize, 10, num_of_digits / 2),
            },
        };
    }

    return .{ .One = stone * 2024 };
}
