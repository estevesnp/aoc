const std = @import("std");

const Field = struct { idx: usize, size: usize };

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var nums = std.ArrayList(?usize).init(allocator);
    defer nums.deinit();

    var id_map = std.AutoHashMap(usize, Field).init(allocator);
    defer id_map.deinit();

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

        const value = blk: {
            if (free_space) {
                break :blk null;
            } else {
                try id_map.put(id, .{ .idx = nums.items.len, .size = times });
                break :blk id;
            }
        };

        const slice = try nums.addManyAsSlice(times);
        @memset(slice, value);
    }

    while (id > 0) {
        id -= 1;
        const field = id_map.getPtr(id).?;
        var spaces: usize = 0;
        for (0..field.idx) |idx| {
            if (nums.items[idx] != null) {
                spaces = 0;
                continue;
            }

            spaces += 1;
            if (spaces >= field.size) {
                const init_idx = idx + 1 - spaces;
                @memset(nums.items[init_idx .. init_idx + spaces], id);
                @memset(nums.items[field.idx .. field.idx + field.size], null);
                field.idx = init_idx;
                break;
            }
        }
    }

    var count: u64 = 0;

    for (nums.items, 0..) |n, idx| {
        if (n) |num| {
            count += num * idx;
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}
