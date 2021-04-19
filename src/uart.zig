const std = @import("std");

pub const Device = struct {
    base: *[8]u8,

    pub const Reader = std.io.Reader(
        *const Device,
        anyerror,
        read,
    );

    pub const Writer = std.io.Writer(
        *const Device,
        anyerror,
        write,
    );

    fn readable(self: *const Device) bool {
        return self.base[5] & 0b00000001 != 0;
    }

    fn read(self: *const Device, buffer: []u8) !usize {
        while (!self.readable()) {
            // wait for data
        }

        var i: usize = 0;
        while (i < buffer.len and self.readable()) {
            buffer[i] = self.base[0];
            i += 1;
        }

        return i;
    }

    fn write(self: *const Device, data: []const u8) !usize {
        for (data) |c| {
            self.base[0] = c;
        }

        return data.len;
    }

    pub fn fromInt(addr: usize) Device {
        return Device{
            .base = @intToPtr(*[8]u8, addr),
        };
    }

    pub fn writer(self: *const Device) Writer {
        return .{ .context = self };
    }

    pub fn reader(self: *const Device) Reader {
        return .{ .context = self };
    }
};
