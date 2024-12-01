const std = @import("std");

const MAX_REDS = 12;
const MAX_GREENS = 13;
const MAX_BLUES = 14;

const Play = struct {
    red: usize = 0,
    green: usize = 0,
    blue: usize = 0,
};

const Colors = enum {
    red,
    green,
    blue,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("../../input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var count: u32 = 0;
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (parseLine(line)) |id| count += id;
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn parseLine(line: []const u8) ?u32 {
    const colon_idx = std.mem.indexOf(u8, line, ":") orelse @panic("no colon found");

    const id = std.fmt.parseInt(u32, line["Game ".len..colon_idx], 10) catch |err|
        std.debug.panic("error parsing id: {any}", .{err});

    var iter = std.mem.tokenizeAny(u8, line[colon_idx + 1 ..], ";");
    while (iter.next()) |play_str| {
        const play = parsePlay(play_str);
        if (!isValidPlay(play)) {
            return null;
        }
    }

    return id;
}

fn parsePlay(line: []const u8) Play {
    var play = Play{};

    var color_iter = std.mem.tokenizeAny(u8, line, ",");
    while (color_iter.next()) |color_pair| {
        var vals_iter = std.mem.tokenizeAny(u8, color_pair, " ");
        const num_str = vals_iter.next() orelse @panic("no number found");
        const num = std.fmt.parseInt(usize, num_str, 10) catch |err|
            std.debug.panic("error parsing num: {any}", .{err});

        const color = vals_iter.next() orelse @panic("no color string found");
        const color_enum = std.meta.stringToEnum(Colors, color) orelse @panic("no expected color found");

        switch (color_enum) {
            .red => play.red = num,
            .green => play.green = num,
            .blue => play.blue = num,
        }
    }

    return play;
}

fn isValidPlay(play: Play) bool {
    return play.red <= MAX_REDS and play.green <= MAX_GREENS and play.blue <= MAX_BLUES;
}

test parsePlay {
    try std.testing.expectEqual(Play{
        .red = 5,
        .blue = 12,
        .green = 12,
    }, parsePlay(" 5 red, 12 blue, 12 green"));

    try std.testing.expectEqual(Play{
        .red = 0,
        .blue = 6,
        .green = 7,
    }, parsePlay(" 6 blue, 7 green"));

    try std.testing.expectEqual(Play{
        .green = 6,
        .blue = 3,
        .red = 2,
    }, parsePlay(" 6 green, 3 blue, 2 red"));
}
