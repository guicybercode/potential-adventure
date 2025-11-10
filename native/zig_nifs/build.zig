const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigler = b.dependency("zigler", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addSharedLibrary(.{
        .name = "zig_nifs",
        .root_source_file = b.path("src/nif.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("zigler", zigler.module("zigler"));
    lib.linkLibC();
    b.installArtifact(lib);
}

