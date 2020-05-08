const Uart = @import("io/uart.zig").Uart;
const io = @import("std").io;

const qputs = @import("io/uart.zig").qputs;

pub const CLI = struct {
    uart: Uart = undefined,

    const Self = @This();

    pub const Error = error{
        failed_to_write,
        failed_to_read,
    };

    pub const OutStream = io.OutStream(Self, Error, Self.put_string);
    pub const InStream = io.InStream(Self, Error, Self.get_string);

    pub fn new() Self {
        return Self{
            .uart =  Uart.new()
        };
    }

    fn put_string(self: Self, string: []const u8) Error!usize {
        return self.uart.puts(string);
    }

    fn get_string(self: Self, buffer: []u8) Error!usize {
        for (buffer) |value, index| {
            var char = self.uart.getc();
            buffer[index] = char;
            self.uart.send(char);
        }

        return buffer.len;
    }

    pub fn get_out_stream(self: Self) OutStream {
        return OutStream{ .context = self };
    }

    pub fn get_in_stream(self: Self) InStream {
        return InStream{ .context = self };
    }
};
