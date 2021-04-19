const UARTDevice = @import("../src/uart.zig").Device;

pub const UART0 = comptime UARTDevice.fromInt(0x101f1000);
pub const UART1 = comptime UARTDevice.fromInt(0x101f2000);
pub const UART2 = comptime UARTDevice.fromInt(0x101f3000);
pub const UART3 = comptime UARTDevice.fromInt(0x10009000);

export const board = comptime @import("../src/board.zig").Board{
    .serial_device = &UART0,
    .gpio_base = null,
};
