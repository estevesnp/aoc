const std = @import("std");

const Play = struct {
    red: u32 = 0,
    green: u32 = 0,
    blue: u32 = 0,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("../../input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var count: u32 = 0;
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        count += parseLine(line);
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn parseLine(line: []const u8) u32 {
    var min_play = Play{};

    const colon_idx = std.mem.indexOf(u8, line, ":") orelse @panic("no colon found");

    var iter = std.mem.tokenizeAny(u8, line[colon_idx + 1 ..], ";");
    while (iter.next()) |play_str| {
        const play = parsePlay(play_str);
        if (play.red > min_play.red) min_play.red = play.red;
        if (play.green > min_play.green) min_play.green = play.green;
        if (play.blue > min_play.blue) min_play.blue = play.blue;
    }

    return min_play.red * min_play.green * min_play.blue;
}

fn parsePlay(line: []const u8) Play {
    var play = Play{};

    var color_iter = std.mem.tokenizeAny(u8, line, ",");
    while (color_iter.next()) |color_pair| {
        var vals_iter = std.mem.tokenizeAny(u8, color_pair, " ");
        const num_str = vals_iter.next() orelse @panic("no number found");
        const num = std.fmt.parseInt(u32, num_str, 10) catch |err|
            std.debug.panic("error parsing num: {any}", .{err});

        const color = vals_iter.next() orelse @panic("no color found");

        if (std.mem.eql(u8, "red", color)) {
            play.red = num;
        } else if (std.mem.eql(u8, "green", color)) {
            play.green = num;
        } else if (std.mem.eql(u8, "blue", color)) {
            play.blue = num;
        } else std.debug.panic("error parsing color: {s}", .{color});
    }

    return play;
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
