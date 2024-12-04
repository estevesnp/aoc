const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

const DO = "do()";
const DONT = "don't()";
const MULTI = "mul(";

const Seq = enum(u1) {
    mul,
    dont,

    const seqs = [_][]const u8{ MULTI, DONT };
    const SeqError = error{TooBig};

    pub fn fromIndex(idx: usize) SeqError!Seq {
        return if (idx > 1) SeqError.TooBig else @enumFromInt(idx);
    }
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var count: u64 = 0;

    var iter = splitMultipleSequences(u8, file, &Seq.seqs);
    while (iter.next()) |container| outer: {
        switch (try Seq.fromIndex(container.sequence_index)) {
            .dont => {
                const do_idx = mem.indexOfPos(u8, file, iter.index, DO) orelse break :outer;
                iter.index = do_idx + DO.len;
            },
            .mul => {
                const comma = mem.indexOfScalarPos(u8, file, iter.index, ',') orelse continue;
                if (comma == file.len - 1) break :outer;
                const paren = mem.indexOfScalarPos(u8, file, comma + 1, ')') orelse continue;

                const first_num = parseInt(u32, file[iter.index..comma], 10) catch continue;
                const second_num = parseInt(u32, file[comma + 1 .. paren], 10) catch continue;

                count += first_num * second_num;
            },
        }
    }

    std.debug.print("RESULT: {}\n", .{count});
}

fn splitMultipleSequences(comptime T: type, buffer: []const T, sequences: []const []const T) MultipleSequenceSplitIterator(T) {
    std.debug.assert(sequences.len > 0);
    return .{
        .index = 0,
        .buffer = buffer,
        .sequences = sequences,
    };
}

fn Container(comptime T: type) type {
    return struct {
        sequence_index: usize,
        token: []const T,
    };
}

fn MultipleSequenceSplitIterator(comptime T: type) type {
    return struct {
        const Self = @This();

        index: usize,
        buffer: []const T,
        sequences: []const []const T,

        fn next(self: *Self) ?Container(T) {
            const container = self.peek() orelse return null;
            self.index += self.sequences[container.sequence_index].len + container.token.len;
            return container;
        }

        fn peek(self: *Self) ?Container(T) {
            var end: usize = self.index;
            const sequence_index: usize = blk: {
                while (end < self.buffer.len) : (end += 1) {
                    if (self.getSequenceIndex(end)) |seq_idx| {
                        break :blk seq_idx;
                    }
                }
                return null;
            };

            return .{
                .sequence_index = sequence_index,
                .token = self.buffer[self.index..end],
            };
        }

        fn getSequenceIndex(self: Self, index: usize) ?usize {
            for (self.sequences, 0..) |seq, idx| {
                if (mem.startsWith(T, self.buffer[index..], seq)) {
                    return idx;
                }
            }
            return null;
        }
    };
}
