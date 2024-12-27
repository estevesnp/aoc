const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const StoneList = std.DoublyLinkedList(usize);

pub fn main() !void {
    const file = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stone_list = StoneList{};

    var iter = mem.tokenizeAny(u8, file, " \n");
    while (iter.next()) |s| {
        const val = try fmt.parseInt(usize, s, 10);
        stone_list.append(try createStone(allocator, val));
    }

    for (0..25) |_| {
        try blink(allocator, &stone_list);
    }

    std.debug.print("RESULT: {}\n", .{stone_list.len});
}

fn blink(allocator: mem.Allocator, stone_list: *StoneList) !void {
    var buf: [256]u8 = undefined;

    var curr_stone = stone_list.first;
    while (curr_stone) |stone| {
        if (stone.data == 0) {
            stone.data = 1;
            curr_stone = stone.next;
            continue;
        }

        const num_str = try fmt.bufPrint(&buf, "{d}", .{stone.data});

        if (num_str.len % 2 == 0) {
            const half = num_str.len / 2;
            const first_num = try fmt.parseInt(usize, num_str[0..half], 10);
            const second_num = try fmt.parseInt(usize, num_str[half..], 10);

            stone.data = first_num;
            const new_stone = try createStone(allocator, second_num);

            stone_list.insertAfter(stone, new_stone);
            curr_stone = new_stone.next;

            continue;
        }

        stone.data *= 2024;
        curr_stone = stone.next;
    }
}

fn createStone(allocator: mem.Allocator, val: usize) !*StoneList.Node {
    const stone = try allocator.create(StoneList.Node);
    stone.data = val;
    return stone;
}
