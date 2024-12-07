const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const parseInt = std.fmt.parseInt;
const panic = std.debug.panic;

const Entry = struct {
    value: u32,
    deps: std.ArrayList(u32),
    found: bool = false,
    active: bool = false,
};

fn Queue(T: type) type {
    return struct {
        list: std.DoublyLinkedList(T),
        allocator: Allocator,

        const Self = @This();
        const Node = std.DoublyLinkedList(T).Node;

        fn init(allocator: Allocator) Self {
            return .{
                .list = std.DoublyLinkedList(T){},
                .allocator = allocator,
            };
        }

        fn enqueue(self: *Self, item: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = item };
            self.list.append(node);
        }

        fn dequeue(self: *Self) ?T {
            const node = self.list.popFirst() orelse return null;
            const value = node.data;
            self.allocator.destroy(node);
            return value;
        }
    };
}

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
    allocator: Allocator,
    dep_map: *std.AutoHashMap(u32, Entry),
    line: []const u8,
) !void {
    const pipe = mem.indexOfScalar(u8, line, '|') orelse
        panic("no pipe in line {s}", .{line});

    const dependency = try parseInt(u32, line[0..pipe], 10);
    const dependant = try parseInt(u32, line[pipe + 1 ..], 10);

    _ = try getOrPutEntry(allocator, dep_map, dependency);
    var dependent_entry = try getOrPutEntry(allocator, dep_map, dependant);

    try dependent_entry.deps.append(dependency);
}

fn getOrPutEntry(
    allocator: Allocator,
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
        const entry = dep_map.getPtr(num) orelse
            panic("no dep_map entry found for {}", .{num});
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
            const dependency = dep_map.get(dep) orelse
                panic("no dep_map entry found for {}", .{dep});
            if (dependency.active and !dependency.found) {
                return try getReorderedEntries(line_entries.items, dep_map);
            }
        }
        entry.found = true;
    }

    return null;
}

fn getReorderedEntries(
    entries: []*Entry,
    dep_map: *std.AutoHashMap(u32, Entry),
) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var dep_graph = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer dep_graph.deinit();

    var ordered_nums = try std.ArrayList(u32).initCapacity(allocator, dep_graph.count());
    defer ordered_nums.deinit();

    var dep_count_tracker = std.AutoHashMap(u32, usize).init(allocator);
    defer dep_count_tracker.deinit();

    for (entries) |entry| {
        if (!entry.active) {
            continue;
        }
        const dependant = entry.value;

        const tracker_entry = try dep_count_tracker.getOrPutValue(dependant, 0);

        for (entry.deps.items) |dependency| {
            const dependency_entry = dep_map.get(dependency) orelse
                panic("no dep_map entry found for {}", .{dependency});

            if (!dependency_entry.active) {
                continue;
            }

            const graph_result = try dep_graph.getOrPut(dependency);
            if (!graph_result.found_existing) {
                graph_result.value_ptr.* = std.ArrayList(u32).init(allocator);
            }
            try graph_result.value_ptr.append(dependant);

            tracker_entry.value_ptr.* += 1;
        }
    }

    var no_deps_queue = Queue(u32).init(allocator);

    var dep_tracker_iter = dep_count_tracker.iterator();
    while (dep_tracker_iter.next()) |entry| {
        if (entry.value_ptr.* == 0) {
            try no_deps_queue.enqueue(entry.key_ptr.*);
        }
    }

    while (no_deps_queue.dequeue()) |dep| {
        try ordered_nums.append(dep);
        _ = dep_count_tracker.remove(dep);

        const dependants = dep_graph.get(dep) orelse
            continue;

        for (dependants.items) |dependant| {
            const count = dep_count_tracker.getPtr(dependant) orelse continue;
            count.* = count.* - 1;
            if (count.* == 0) {
                try no_deps_queue.enqueue(dependant);
            }
        }
    }

    if (ordered_nums.items.len != entries.len) {
        return error.InvalidEntries;
    }

    return ordered_nums.items[ordered_nums.items.len / 2];
}
