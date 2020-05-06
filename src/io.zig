pub const Uart = @import("io/uart.zig").Uart;


var uart: Uart = undefined;

pub var out: Uart.OutStream = undefined;
pub var in: Uart.InStream = undefined;

pub fn init_uart() void {
    uart = Uart.new();
    out = uart.get_out_stream();
    in = uart.get_in_stream();
}