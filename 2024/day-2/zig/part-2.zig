const std = @import("std");
const mem = std.mem;
const math = std.math;

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var nums = std.ArrayList(u32).init(arena.allocator());
    defer nums.deinit();

    var count: u32 = 0;

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        nums.clearRetainingCapacity();

        var num_iter = mem.tokenizeScalar(u8, line, ' ');
        while (num_iter.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try nums.append(num);
        }

        if (isSafeReport(nums.items)) count += 1;
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn isSafeReport(report: []u32) bool {
    if (report.len < 2) return true;

    if (isSafeSequence(report, null)) return true;

    for (0..report.len) |idx| {
        if (isSafeSequence(report, idx)) return true;
    }

    return false;
}

fn isSafeSequence(report: []u32, skip_idx: ?usize) bool {
    var cur_num: ?u32 = null;
    var cur_order: ?math.Order = null;

    for (report, 0..) |num, idx| {
        if (skip_idx) |s_idx| if (idx == s_idx) continue;

        defer cur_num = num;
        if (cur_num == null) continue;

        const diff = @abs(@as(i32, @intCast(cur_num.?)) - @as(i32, @intCast(num)));

        if (diff == 0 or diff > 3) return false;

        const order = math.order(cur_num.?, num);
        if (cur_order == null) {
            cur_order = order;
            continue;
        }

        if (cur_order.? != order) return false;
    }

    return true;
}
