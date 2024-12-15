const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const part_1 = b.addExecutable(.{
        .name = "ziglab",
        .root_source_file = b.path("part-1.zig"),
        .target = target,
        .optimize = optimize,
    });

    const part_2 = b.addExecutable(.{
        .name = "ziglab",
        .root_source_file = b.path("part-2.zig"),
        .target = target,
        .optimize = optimize,
    });

    // For ZLS diagnostics
    const check = b.step("check", "Check if project compiles");
    check.dependOn(&part_1.step);
    check.dependOn(&part_2.step);
}
