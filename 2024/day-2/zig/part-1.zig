const std = @import("std");
const mem = std.mem;
const math = std.math;

pub fn main() !void {
    const file = @embedFile("input.txt");

    var count: u32 = 0;

    var iter = mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        if (isSafeReport(line)) count += 1;
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn isSafeReport(report: []const u8) bool {
    var iter = mem.tokenizeScalar(u8, report, ' ');

    var cur_num: ?u32 = null;
    var cur_order: ?math.Order = null;

    while (iter.next()) |str| {
        const num = std.fmt.parseInt(u8, str, 10) catch @panic("error parsing int");
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
