const std = @import("std");

extern fn main() void;

fn ldr_params() []const u8 {
    const arch = std.Target.current.cpu.arch;
    return switch (arch) {
        .arm => "sp, =sp_top",
        .aarch64 => "x2, sp_top",
        else => std.debug.panic("unsupported cpu arch: {}\n", .{arch}),
    };
}

comptime {
    asm (
        \\.global _Start;
        \\.type _Start, #function;
        \\_Start:
        ++
         "  LDR " ++ ldr_params() ++ "\n"
        ++
        \\  BL main
        \\  B .
    );
}

// export fn _Start() noreturn {
//     asm volatile ("LDR " ++ comptime ldr_params());

//     // asm volatile ("LDR x2, sp_top");
//     // asm volatile ("LDR sp, =sp_top");

//     main();

//     while (true) {}
// }
