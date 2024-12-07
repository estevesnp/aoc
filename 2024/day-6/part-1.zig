const std = @import("std");
const mem = std.mem;
const panic = std.debug.panic;
const expectEqual = std.testing.expectEqual;

const OBSTACLE = '#';

const Point = struct { row: usize, col: usize };
const Guard = struct {
    pos: Point,
    direction: Direction,

    const Direction = enum {
        up,
        down,
        left,
        right,

        fn fromCharacter(char: u8) ?Direction {
            return switch (char) {
                '^' => .up,
                'v' => .down,
                '<' => .left,
                '>' => .right,
                else => null,
            };
        }

        fn toVector(self: Guard.Direction) [2]i32 {
            return switch (self) {
                .up => .{ -1, 0 },
                .down => .{ 1, 0 },
                .left => .{ 0, -1 },
                .right => .{ 0, 1 },
            };
        }

        fn nextDirection(self: Guard.Direction) Direction {
            return switch (self) {
                .up => .right,
                .right => .down,
                .down => .left,
                .left => .up,
            };
        }
    };
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var matrix = std.ArrayList([]const u8).init(allocator);
    defer matrix.deinit();

    var guard: Guard = undefined;

    var iter = mem.tokenizeScalar(u8, file, '\n');
    var row: usize = 0;
    while (iter.next()) |line| : (row += 1) {
        try matrix.append(line);
        if (findGuard(line, row)) |g| guard = g;
    }

    std.debug.print("RESULT: {}\n", .{try countSteps(&guard, matrix.items, allocator)});
}

fn findGuard(line: []const u8, row: usize) ?Guard {
    for (line, 0..) |char, col| {
        const direction = Guard.Direction.fromCharacter(char) orelse continue;
        return Guard{
            .direction = direction,
            .pos = Point{ .row = row, .col = col },
        };
    }

    return null;
}

fn countSteps(guard: *Guard, matrix: [][]const u8, allocator: std.mem.Allocator) !u32 {
    var step_set = std.AutoHashMap(Point, void).init(allocator);
    defer step_set.deinit();

    try step_set.put(guard.pos, {});

    while (updatePosition(guard, matrix)) |pos| {
        try step_set.put(pos, {});
    }

    return step_set.count();
}

fn updatePosition(guard: *Guard, matrix: []const []const u8) ?Point {
    const rows = matrix.len;
    const cols = matrix[0].len;

    var curr_direction = guard.direction;

    var forward_row: i32 = undefined;
    var forward_col: i32 = undefined;

    while (true) : (curr_direction = curr_direction.nextDirection()) {
        const vector = curr_direction.toVector();
        forward_row = @as(i32, @intCast(guard.pos.row)) + vector[0];
        forward_col = @as(i32, @intCast(guard.pos.col)) + vector[1];

        if (forward_row < 0 or forward_row >= rows or forward_col < 0 or forward_col >= cols) {
            return null;
        }

        const next_char = matrix[@as(usize, @intCast(forward_row))][@as(usize, @intCast(forward_col))];
        if (next_char != OBSTACLE) break;
        if (curr_direction.nextDirection() == guard.direction) {
            panic("got stuck on row {}, col {}", .{ guard.pos.row, guard.pos.col });
        }
    }

    guard.pos = .{ .row = @intCast(forward_row), .col = @intCast(forward_col) };
    guard.direction = curr_direction;

    return guard.pos;
}

test updatePosition {
    var g: Guard = undefined;
    const guard = &g;

    resetGuard(guard, .right, null);
    try expectGuard(
        .right,
        .{ .row = 1, .col = 2 },
        guard,
        &.{
            "...",
            ".>.",
            "...",
        },
    );

    resetGuard(guard, .down, null);
    try expectGuard(
        .left,
        .{ .row = 1, .col = 0 },
        guard,
        &.{
            "...",
            ".v.",
            ".#.",
        },
    );

    resetGuard(guard, .left, null);
    try expectGuard(
        .right,
        .{ .row = 1, .col = 2 },
        guard,
        &.{
            ".#.",
            "#<.",
            "...",
        },
    );

    resetGuard(guard, .up, null);
    try expectGuard(
        .up,
        null,
        guard,
        &.{
            ".#.",
            "#^#",
            ".#.",
        },
    );

    resetGuard(guard, .up, .{ .row = 0, .col = 1 });
    try expectGuard(
        .up,
        null,
        guard,
        &.{
            ".^.",
            "...",
            "...",
        },
    );

    resetGuard(guard, .left, .{ .row = 0, .col = 1 });
    try expectGuard(
        .left,
        null,
        guard,
        &.{
            "#<.",
            "...",
            "...",
        },
    );

    resetGuard(guard, .left, .{ .row = 2, .col = 1 });
    try expectGuard(
        .left,
        null,
        guard,
        &.{
            "...",
            ".#.",
            "#<#",
        },
    );
}

fn resetGuard(guard_ptr: *Guard, dir: Guard.Direction, position: ?Point) void {
    guard_ptr.* = .{
        .direction = dir,
        .pos = position orelse .{ .row = 1, .col = 1 },
    };
}

fn expectGuard(
    expected_dir: Guard.Direction,
    expected_point: ?Point,
    guard_ptr: *Guard,
    matrix: []const []const u8,
) !void {
    try expectEqual(expected_point, updatePosition(guard_ptr, matrix));
    if (expected_point) |point| {
        try expectEqual(point, guard_ptr.pos);
    }
    try expectEqual(expected_dir, guard_ptr.direction);
}
