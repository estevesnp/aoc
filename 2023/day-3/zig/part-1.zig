const std = @import("std");

const Point = struct {
    col: usize,
    row: usize,

    fn derive(self: Point, col: i32, row: i32) Point {
        return .{
            .col = @abs(col + @as(i32, @intCast(self.col))),
            .row = @abs(row + @as(i32, @intCast(self.row))),
        };
    }
};
const NumPoint = struct { val: u32, point: Point };

pub fn main() !void {
    const file = @embedFile("input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    _ = gpa.detectLeaks();

    var line_list = std.ArrayList([]const u8).init(allocator);
    defer line_list.deinit();

    var point_list = std.ArrayList(Point).init(allocator);
    defer point_list.deinit();

    var point_set = std.AutoHashMap(Point, void).init(allocator);
    defer point_set.deinit();

    var row: usize = 0;

    var iter = std.mem.tokenizeAny(u8, file, "\n");
    while (iter.next()) |line| : (row += 1) {
        try line_list.append(line);
        try parseLine(&point_list, line, row);
    }

    var num_points: [8]?NumPoint = undefined;

    var count: u64 = 0;
    for (point_list.items) |point| {
        num_points = .{null} ** 8;
        try parsePoint(&num_points, point, line_list.items);

        for (num_points) |num_point| {
            if (num_point == null) continue;
            const get_put = try point_set.getOrPut(num_point.?.point);
            if (get_put.found_existing) continue;
            count += num_point.?.val;
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn parseLine(point_list: *std.ArrayList(Point), line: []const u8, row: usize) !void {
    for (line, 0..) |char, col| {
        if (char == '.' or std.ascii.isDigit(char)) continue;
        try point_list.append(Point{ .col = col, .row = row });
    }
}

fn parsePoint(num_points: *[8]?NumPoint, point: Point, lines: [][]const u8) !void {
    var count: usize = 0;

    const cols = lines[0].len - 1;
    const rows = lines.len - 1;

    var rel_cols = [_]?i8{ null, 0, null };
    var rel_rows = [_]?i8{ null, 0, null };

    if (point.col > 0) rel_cols[0] = -1;
    if (point.col < cols) rel_cols[2] = 1;

    if (point.row > 0) rel_rows[0] = -1;
    if (point.row < rows) rel_rows[2] = 1;

    for (rel_rows) |rel_row| {
        if (rel_row == null) continue;
        for (rel_cols) |rel_col| {
            if (rel_col == null) continue;

            if (rel_row.? == 0 and rel_col.? == 0) {
                continue;
            }

            const to_check = point.derive(rel_col.?, rel_row.?);
            if (try checkNum(to_check, lines[to_check.row])) |num_point| {
                num_points[count] = num_point;
                count += 1;
            }
        }
    }
}

fn checkNum(point: Point, line: []const u8) !?NumPoint {
    if (!std.ascii.isDigit(line[point.col])) return null;

    var start: usize = point.col;
    var end: usize = point.col;

    while (start > 0 and std.ascii.isDigit(line[start - 1])) start -= 1;
    while (end < line.len - 1 and std.ascii.isDigit(line[end + 1])) end += 1;

    const num = try std.fmt.parseInt(u32, line[start .. end + 1], 10);

    return .{
        .val = num,
        .point = .{
            .col = start,
            .row = point.row,
        },
    };
}
