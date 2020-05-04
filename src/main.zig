// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const uart = @import("uart.zig");

export fn main() noreturn {
    var out = uart.Uart{};
    out.init();
    var stream = out.getStream();
    stream.print("Hello, {}!\n", .{"world"}) catch {};

    while(true) {
    //    uart.send(uart.getc());
    }

}
