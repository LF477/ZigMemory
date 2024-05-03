const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{}); // Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall

    const lib = b.addStaticLibrary(.{
        .name = "ZigMemory",
        .root_source_file = b.path("src/root.zig"), // path for lib
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib); // library to be installed into the standard location

    const exe = b.addExecutable(.{
        .name = "ZigMemory",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe); // executable to be installed into the standard location

    const run_cmd = b.addRunArtifact(exe); // Run step in the build graph
    run_cmd.step.dependOn(b.getInstallStep()); // will be run from the installation directory rather than directly from within the cache directory

    if (b.args) |args| {
        run_cmd.addArgs(args); // pass arguments to the application in the build `zig build run -- arg1 arg2 etc`
    }

    const run_step = b.step("run", "Run the app"); // only run
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    //

    const test_step = b.step("test", "Run unit tests"); // `test` step to the `zig build --help` menu
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
