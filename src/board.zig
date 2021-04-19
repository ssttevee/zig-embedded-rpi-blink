const std = @import("std");
const UARTDevice = @import("uart.zig").Device;

pub const Board = struct {
    serial_device: ?*const UARTDevice,
    gpio_base: ?[*]volatile u32,

    pub fn writer(self: *const Board) ?UARTDevice.Writer {
        if (self.serial_device) |dev| {
            return dev.writer();
        }

        return null;
    }

    pub fn reader(self: *const Board) ?UARTDevice.Reader {
        if (self.serial_device) |dev| {
            return dev.reader();
        }

        return null;
    }
};

// fn findBoard() *const Board {
//     const root = @import("root");
//     if (@hasDecl(root, "board")) {
//         return &root.board;
//     }

//     @panic("board not supported or bad build config");
// }

// pub const board: *const Board = comptime findBoard();
