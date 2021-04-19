const std = @import("std");

const Board = enum {
    versatilepb,
    raspi,
    raspi2,
    raspi3,
    raspi4,

    fn cpu_arch(self: Board) std.Target.Cpu.Arch {
        return switch (self) {
            .versatilepb, .raspi, .raspi2 => .arm,
            .raspi3, .raspi4 => .aarch64,
        };
    }

    fn cpu_model(self: Board) *const std.Target.Cpu.Model {
        return switch (self) {
            .versatilepb => &std.Target.arm.cpu.arm926ej_s,
            .raspi => &std.Target.arm.cpu.arm1176jzf_s,
            .raspi2 => &std.Target.arm.cpu.cortex_a7,
            .raspi3 => &std.Target.aarch64.cpu.cortex_a53,
            .raspi4 => &std.Target.aarch64.cpu.cortex_a72,
        };
    }

    fn cross_target(self: Board) std.zig.CrossTarget {
        return .{
            .cpu_arch = self.cpu_arch(),
            .cpu_model = .{
                .explicit = self.cpu_model(),
            },
            .os_tag = .freestanding,
            .abi = .none,
        };
    }
};

pub fn build(b: *std.build.Builder) void {
    const board = b.option(Board, "board", "target board") orelse Board.raspi2;

    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{
        .default_target = board.cross_target(),
    });

    // const exe = b.addExecutable("firmware.elf", "startup.zig");
    const exe = b.addExecutable("firmware.elf", "main.zig");
    exe.addAssemblyFile("boot.s");
    exe.setTarget(target);

    // const boardPathPrefix = "boards/";
    // const boardName = @tagName(board);
    // const boardPathSuffix = ".zig";

    // const maxBoardPathLength = 32;
    // const boardPathLength = boardPathPrefix.len+boardName.len+boardPathSuffix.len;
    // if (boardPathLength > maxBoardPathLength) {
    //     std.debug.panic("board name is too long: {s} (over by {d})", .{boardName, boardPathLength - maxBoardPathLength});
    // }

    // var boardPath: [maxBoardPathLength]u8 = undefined;
    // std.mem.copy(u8, boardPath[0..], boardPathPrefix[0..]);
    // std.mem.copy(u8, boardPath[boardPathPrefix.len..], boardName[0..]);
    // std.mem.copy(u8, boardPath[boardPathPrefix.len+boardName.len..], boardPathSuffix[0..]);

    // const boardObj = b.addObject("board", boardPath[0..boardPathLength]);
    // boardObj.main_pkg_path = ".";
    // boardObj.setTarget(target);
    // boardObj.link_function_sections = true;
    // exe.addObject(boardObj);

    // const mainObj = b.addObject("main", "main.zig");
    // mainObj.setTarget(target);
    // mainObj.link_function_sections = true;
    // exe.addObject(mainObj);

    exe.setBuildMode(mode);
    exe.setLinkerScriptPath("linker.ld");
    exe.setOutputDir(".");
    exe.link_function_sections = true;

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
