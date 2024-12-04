const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

const DO = "do()";
const DONT = "don't()";
const MUL = "mul(";

const Seq = enum {
    mul,
    dont,
    other,

    fn toString(self: Seq) []const u8 {
        return switch (self) {
            .mul => MUL,
            .dont => DONT,
            .other => unreachable,
        };
    }
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var count: u64 = 0;

    var idx: usize = 0;
    while (idx < file.len) {
        switch (getSeq(file, idx)) {
            .mul => count += parseMul(file, &idx),
            .dont => idx = goToDo(file, idx),
            .other => idx += 1,
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn getSeq(input: []const u8, idx: usize) Seq {
    inline for (std.meta.fields(Seq)) |field| {
        const val: Seq = @field(Seq, field.name);
        if (val == Seq.other) continue;

        const str = val.toString();
        if (mem.eql(u8, str, input[idx .. idx + str.len])) return val;
    }
    return Seq.other;
}

fn parseMul(input: []const u8, idx: *usize) u32 {
    defer idx.* += 1;
    const comma = mem.indexOfScalarPos(u8, input, idx.* + MUL.len, ',') orelse return 0;
    const paren = mem.indexOfScalarPos(u8, input, comma + 1, ')') orelse return 0;

    const first_num = parseInt(u32, input[idx.* + MUL.len .. comma], 10) catch return 0;
    const second_num = parseInt(u32, input[comma + 1 .. paren], 10) catch return 0;

    idx.* = paren;
    return first_num * second_num;
}

fn goToDo(input: []const u8, idx: usize) usize {
    const do_idx = mem.indexOfPos(u8, input, idx, DO) orelse return input.len;
    return do_idx + DO.len;
}
