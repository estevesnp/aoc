const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

const Entry = struct {
    value: u32,
    deps: std.ArrayList(u32),
    found: bool = false,
    active: bool = false,
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var dep_map = std.AutoHashMap(u32, Entry).init(allocator);
    defer dep_map.deinit();

    var iter = mem.splitScalar(u8, file, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) break;
        try fillMap(allocator, &dep_map, line);
    }

    var line_entries = std.ArrayList(*Entry).init(allocator);
    defer line_entries.deinit();

    var count: u32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;

        line_entries.clearRetainingCapacity();
        if (try checkLine(&line_entries, &dep_map, line)) |mid| {
            count += mid;
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn fillMap(
    allocator: std.mem.Allocator,
    dep_map: *std.AutoHashMap(u32, Entry),
    line: []const u8,
) !void {
    const pipe = mem.indexOfScalar(u8, line, '|') orelse @panic("no pipe");
    const dependency = try parseInt(u32, line[0..pipe], 10);
    const dependant = try parseInt(u32, line[pipe + 1 ..], 10);

    _ = try getOrPutEntry(allocator, dep_map, dependency);
    var dependent_entry = try getOrPutEntry(allocator, dep_map, dependant);

    try dependent_entry.deps.append(dependency);
}

fn getOrPutEntry(
    allocator: std.mem.Allocator,
    dep_map: *std.AutoHashMap(u32, Entry),
    dep: u32,
) !*Entry {
    const dep_result = try dep_map.getOrPut(dep);
    if (!dep_result.found_existing) {
        dep_result.value_ptr.* = .{
            .value = dep,
            .deps = std.ArrayList(u32).init(allocator),
        };
    }
    return dep_result.value_ptr;
}

fn checkLine(
    line_entries: *std.ArrayList(*Entry),
    dep_map: *std.AutoHashMap(u32, Entry),
    line: []const u8,
) !?u32 {
    var iter = mem.tokenizeScalar(u8, line, ',');
    while (iter.next()) |num_str| {
        const num = try parseInt(u32, num_str, 10);
        const entry = dep_map.getPtr(num) orelse @panic("no dep");
        try line_entries.append(entry);

        entry.active = true;
    }

    defer {
        for (line_entries.items) |entry| {
            entry.found = false;
            entry.active = false;
        }
    }

    for (line_entries.items) |entry| {
        for (entry.deps.items) |dep| {
            const dependency = dep_map.get(dep) orelse @panic("no dep again");
            if (dependency.active and !dependency.found) {
                return null;
            }
        }
        entry.found = true;
    }

    return line_entries.items[line_entries.items.len / 2].value;
}
