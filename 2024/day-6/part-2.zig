const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;

const OBSTACLE = '#';

const Point = struct { row: usize, col: usize };

const Guard = struct { point: Point, direction: Direction };

const Result = enum { proceed, exit, loop };

const Visit = struct {
    visited_up: bool = false,
    visited_right: bool = false,
    visited_down: bool = false,
    visited_left: bool = false,
};

const Direction = enum {
    up,
    right,
    down,
    left,

    fn next(self: Direction) Direction {
        return switch (self) {
            .up => .right,
            .right => .down,
            .down => .left,
            .left => .up,
        };
    }

    fn toVector(self: Direction) [2]i32 {
        return switch (self) {
            .up => .{ -1, 0 },
            .right => .{ 0, 1 },
            .down => .{ 1, 0 },
            .left => .{ 0, -1 },
        };
    }
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var matrix = std.ArrayList([]u8).init(allocator);
    defer matrix.deinit();

    var guard: ?Guard = null;

    var iter = mem.tokenizeScalar(u8, file, '\n');

    while (iter.next()) |line| {
        if (guard == null) {
            guard = findGuard(line, matrix.items.len);
        }

        try matrix.append(try allocator.dupe(u8, line));
    }

    std.debug.assert(guard != null);

    const count = try checkForLoops(&guard.?, matrix.items, allocator);
    std.debug.print("RESULT: {}\n", .{count});
}

fn checkForLoops(guard: *Guard, matrix: [][]u8, allocator: Allocator) !usize {
    var visit_map = std.AutoHashMap(Point, Visit).init(allocator);
    defer visit_map.deinit();

    var count: usize = 0;
    while (true) {
        if (try runSimulation(guard, &visit_map, matrix) == .loop) count += 1;
        if (try walk(guard, &visit_map, matrix) != .proceed) break;
    }

    return count;
}

fn runSimulation(
    guard: *Guard,
    visit_map: *std.AutoHashMap(Point, Visit),
    matrix: [][]u8,
) !Result {
    var sim_guard = Guard{ .point = guard.point, .direction = guard.direction };
    const next_point = getNextPoint(&sim_guard, matrix) orelse return .exit;
    sim_guard.direction = guard.direction;

    const next_block = matrix[next_point.row][next_point.col];
    switch (next_block) {
        '^', '>', 'v', '<' => return .exit,
        else => {},
    }

    if (visit_map.get(next_point) != null) return .exit;

    matrix[next_point.row][next_point.col] = OBSTACLE;
    defer matrix[next_point.row][next_point.col] = next_block;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var sim_map = try visit_map.cloneWithAllocator(allocator);

    var result = Result.proceed;
    while (result == .proceed) {
        result = try walk(&sim_guard, &sim_map, matrix);
    }

    return result;
}

fn getNextPoint(guard: *Guard, matrix: [][]u8) ?Point {
    const rows = matrix.len;
    const cols = matrix[0].len;

    var next_point: Point = undefined;
    var curr_direction = guard.direction;

    while (true) : (curr_direction = curr_direction.next()) {
        next_point = applyVector(guard.point, curr_direction.toVector()) orelse {
            return null;
        };
        if (next_point.row >= rows or next_point.col >= cols) return null;

        if (matrix[next_point.row][next_point.col] != OBSTACLE) break;
        if (curr_direction.next() == guard.direction) {
            std.debug.panic("got stuck on row {} col {}", .{
                guard.point.row,
                guard.point.col,
            });
        }
    }

    guard.direction = curr_direction;

    return next_point;
}

fn walk(
    guard: *Guard,
    visit_map: *std.AutoHashMap(Point, Visit),
    matrix: [][]u8,
) !Result {
    const next_point = getNextPoint(guard, matrix) orelse return .exit;

    const res = try visit_map.getOrPut(guard.point);
    if (!res.found_existing) {
        res.value_ptr.* = Visit{};
    }
    if (updateVisit(res.value_ptr, guard.direction)) return .loop;

    guard.point = next_point;

    return .proceed;
}

fn findGuard(line: []const u8, row: usize) ?Guard {
    for (line, 0..) |char, col| {
        const point = Point{ .row = row, .col = col };
        switch (char) {
            '^' => return Guard{ .point = point, .direction = .up },
            '>' => return Guard{ .point = point, .direction = .right },
            'v' => return Guard{ .point = point, .direction = .down },
            '<' => return Guard{ .point = point, .direction = .left },
            else => {},
        }
    }
    return null;
}

fn applyVector(point: Point, vector: [2]i32) ?Point {
    const row = @as(i32, @intCast(point.row)) + vector[0];
    const col = @as(i32, @intCast(point.col)) + vector[1];

    if (row < 0 or col < 0) return null;
    return Point{ .row = @intCast(row), .col = @intCast(col) };
}

fn updateVisit(visit: *Visit, direction: Direction) bool {
    switch (direction) {
        .up => {
            if (visit.visited_up) return true;
            visit.visited_up = true;
        },
        .right => {
            if (visit.visited_right) return true;
            visit.visited_right = true;
        },
        .down => {
            if (visit.visited_down) return true;
            visit.visited_down = true;
        },
        .left => {
            if (visit.visited_left) return true;
            visit.visited_left = true;
        },
    }
    return false;
}
