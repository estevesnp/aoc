const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const parseInt = std.fmt.parseInt;

const Op = enum { sum, mult };

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var nums = std.ArrayList(u32).init(arena.allocator());
    defer nums.deinit();

    var count: u64 = 0;

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        if (try parseLine(line, &nums)) |res| {
            count += res;
        }
        nums.clearRetainingCapacity();
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn parseLine(line: []const u8, nums_list: *std.ArrayList(u32)) !?u64 {
    const colon_idx = mem.indexOfScalar(u8, line, ':') orelse return null;
    const goal = try parseInt(u64, line[0..colon_idx], 10);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var iter = mem.tokenizeScalar(u8, line[colon_idx + 1 ..], ' ');
    while (iter.next()) |num_str| {
        try nums_list.append(try parseInt(u32, num_str, 10));
    }

    if (recurs(goal, nums_list.items[0], nums_list.items[1..])) return goal;

    return null;
}

fn recurs(goal: u64, curr: u64, nums: []u32) bool {
    if (nums.len == 0) {
        return goal == curr;
    }

    return recurs(goal, curr + nums[0], nums[1..]) or
        recurs(goal, curr * nums[0], nums[1..]);
}
