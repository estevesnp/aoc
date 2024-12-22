const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var nums = std.ArrayList(?usize).init(allocator);
    defer nums.deinit();

    var id: usize = 0;
    var free_space = false;
    for (file) |num| {
        if (num < '0' or num > '9') break;

        defer {
            if (!free_space) id += 1;
            free_space = !free_space;
        }

        const times = num - '0';
        if (times == 0) continue;

        const char = if (free_space) null else id;

        const slice = try nums.addManyAsSlice(times);
        @memset(slice, char);
    }

    var count: u64 = 0;
    var last_idx = nums.items.len - 1;

    for (nums.items, 0..) |num, idx| {
        if (idx > last_idx) break;

        const val = num orelse blk: {
            while (nums.items[last_idx] == null) last_idx -= 1;
            defer last_idx -= 1;
            break :blk nums.items[last_idx].?;
        };

        count += idx * val;
    }

    std.debug.print("RESULT: {}\n", .{count});
}
