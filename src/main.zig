// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const cli = @import("console.zig").CLI;
const io = @import("io.zig");
const timer = @import("timer.zig");

const power = @import("power.zig");
const std = @import("std");
const mem = @import("mem.zig");
const arm = @import("arm.zig");
const Allocator = std.mem.Allocator;

const Command = enum {
    reset,
    nop,

    fn to_string(self: Command) []const u8 {
        switch (self) {
            .reset => {
                return "Restarting";
            },
            .nop => {
                return "Command not found";
            },
        }
    }
};

fn parse_command(command: []u8) Command {
    if (std.mem.eql(u8, command, "reset")) {
        return Command.reset;
    } else {
        return Command.nop;
    }
}

pub fn main() noreturn {
    mem.init();
    const allocator = &std.heap.FixedBufferAllocator.init(&mem.heap).allocator;
    var console = cli.new();

    var in = console.get_in_stream();
    var out = console.get_out_stream();

    out.print("\n", .{}) catch{};
    
    io.gpio.set_pin_mode(17, io.gpio.Mode.output);
    
    var state = false;
    while(true) {
        io.gpio.output_set(17, state);
        timer.wait_msec(1000);
        out.print("Pin 17: {}\n", .{state}) catch {};
        state = !state;
    }

    // while (true) {
        // out.print("> ", .{}) catch {};
        // var line = in.readUntilDelimiterAlloc(allocator, '\n', 100) catch undefined;
        // defer allocator.destroy(&line);
        // if (line.len > 0) {
            // out.print("{}\n", .{parse_command(line).to_string()}) catch {};
        // }
    // }
}
