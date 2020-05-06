// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const io = @import("io.zig");

export fn main() noreturn {
    var uart = io.Uart.new();
    var stream = uart.get_stream();
    stream.print("Hello, {}! \n", .{"world"}) catch {};

    while(true) {
        //out.send(out.getc());
    }

}
