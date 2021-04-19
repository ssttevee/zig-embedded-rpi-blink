pub const peripheral_base_addr: usize = 0xFE000000;

pub const gpio_base_addr = peripheral_base_addr + 0x00200000;

export const board = comptime @import("../src/board.zig").Board{
    .serial_device = null,
    .gpio_base = @intToPtr([*]u32, gpio_base_addr),
};
