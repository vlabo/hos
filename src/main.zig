// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const io = @import("cli.zig");
const timer = @import("timer.zig");

const power = @import("power.zig");
const std = @import("std");
const mem = @import("mem.zig");
const Allocator = std.mem.Allocator;

const Command = enum {
    reset,
    nop,
};


fn process_command(command: []u8) Command {
    if(std.mem.eql(u8, command, "reset")) {
        return Command.reset;
    } else {
        return Command.nop;
    }
}

export fn main() noreturn {
    const allocator = &std.heap.FixedBufferAllocator.init(&mem.heap).allocator;
    var console = io.CLI.new();
    
    var in = console.get_in_stream();
    var out = console.get_out_stream();

    while (true) {
        out.print("> ", .{}) catch {};
        var line = in.readUntilDelimiterAlloc(allocator, '\n', 100) catch undefined;
        defer allocator.destroy(&line);
        if (line.len > 0) {
            switch (process_command(line)) {
                .reset => { 
                    out.print("Restarting\n", .{}) catch {};
                    power.reset();
                    } ,
                .nop => out.print("Command '{}' not found.\n", .{line}) catch {},
            }
        }
    }
}
