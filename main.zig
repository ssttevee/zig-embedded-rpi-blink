const std = @import("std");

// extern const board: @import("src/board.zig").Board;

// Define root.log to override the std implementation
pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    if (board.writer()) |writer| {
        // Ignore all non-critical logging from sources other than
        // .my_project, .nice_library and .default
        const scope_prefix = "(" ++ switch (scope) {
            .my_project, .nice_library, .default => @tagName(scope),
            else => if (@enumToInt(level) <= @enumToInt(std.log.Level.crit))
                @tagName(scope)
            else
                return,
        } ++ "): ";

        const prefix = "[" ++ @tagName(level) ++ "] " ++ scope_prefix;

        // Print the message to uart0, silently ignoring any errors
        nosuspend std.fmt.format(writer, prefix ++ format ++ "\n", args) catch return;
    }
}

fn sleep(ticks: usize) void {
    var i: usize = 0;
    while (i < ticks) {
        i += 1;
    }
}

extern fn _park() noreturn;

export fn _enter_zig() noreturn {
    // if (board.gpio_base) |gpio| {
    //     const addr = @ptrToInt(gpio);
    //     // gpio[4] |= 1 << 6;
    //     // gpio[11] = 1 << 10;
    // }

    const base = comptime @intToPtr([*]volatile u32, 0xFE200000);
    // @intToPtr(*volatile u32, 0xFE200010).* |= 1 << 6;
    base[0x10] |= comptime 1 << 6;

    while (true) {
        sleep(500000);
        base[0x20] = comptime 1 << 10;
        // @intToPtr(*volatile u32, 0xFE200020).* = 1 << 10;
        sleep(500000);
        base[0x2C] = comptime 1 << 10;
        // @intToPtr(*volatile u32, 0xFE20002C).* = 1 << 10;
    }

    // std.log.info("hello world!", .{});
    // var buf: [256]u8 = undefined;

    // while (true) {
    //     const line = UART0.reader().readUntilDelimiterOrEof(&buf, '\n');
    //     std.log.info("received: {s}", .{line});
    // }

    _park();
}
