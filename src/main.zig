// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const io = @import("cli.zig");
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

export fn _start() noreturn {
    if(arm.get_cpu_id() & 0x3 != 0) {
        arm.wfi();
    }
    asm volatile (
        \\ ldr     x1, =_start
        \\ mov     sp, x1
    );
    setup();
}

noinline fn setup() noreturn {
    mem.init();
    main();
}

fn main() noreturn {
    const allocator = &std.heap.FixedBufferAllocator.init(&mem.heap).allocator;
    var console = io.CLI.new();

    var in = console.get_in_stream();
    var out = console.get_out_stream();

    out.print("\n", .{}) catch{};

    while (true) {
        out.print("> ", .{}) catch {};
        var line = in.readUntilDelimiterAlloc(allocator, '\n', 100) catch undefined;
        defer allocator.destroy(&line);
        if (line.len > 0) {
            out.print("{}\n", .{parse_command(line).to_string()}) catch {};
        }
    }
}
