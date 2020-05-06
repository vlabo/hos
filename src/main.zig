// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const io = @import("io.zig");
const timer = @import("timer.zig");

const power = @import("power.zig");

export fn main() noreturn {
    io.init_uart();
    io.out.print("Hello, {}! \n", .{"world"}) catch {};
    var buffer: [4]u8 = .{0,0,0,0};
    var size = io.in.read(&buffer) catch 0;

    io.out.print("\n", .{}) catch {};

    //timer.wait_msec(1000 * 5);

    //power.reset();

    while(true) {
        io.out.print("1 sec. \n", .{}) catch {};
        timer.wait_msec(1000);
    }

}
