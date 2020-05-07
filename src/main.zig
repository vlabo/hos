// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const io = @import("io.zig");
const timer = @import("timer.zig");

const power = @import("power.zig");
const std = @import("std");
const Allocator = std.mem.Allocator;

var heap: [1024 * 4]u8 = undefined;


fn concat(allocator: *Allocator, a: []const u8, b: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    std.mem.copy(u8, result, a);
    std.mem.copy(u8, result[a.len..], b);
    return result;
}

export fn main() noreturn {

    const allocator = &std.heap.FixedBufferAllocator.init(&heap).allocator;

    io.init_uart();
    io.out.print("Hello, {}! \n", .{"world"}) catch {};
    var buffer: [4]u8 = .{0,0,0,0};
    var line = io.in.readUntilDelimiterAlloc(allocator, '\n', 100) catch undefined;
    defer allocator.destroy(&line);

    const result = concat(allocator, "command: ", line) catch undefined;
    defer allocator.destroy(&result);
    
    io.out.print("\n{}\n", .{ result }) catch {};

    while(true) {
        io.out.print("1 sec. \n", .{}) catch {};
        timer.wait_msec(1000);
    }

}
