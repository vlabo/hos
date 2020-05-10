// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

pub inline fn nop() void {
    asm volatile ("nop");
}

pub inline fn wfe() void {
    asm volatile("wfe");
}

pub inline fn wfi() void {
    asm volatile("wfi");
}

pub inline fn get_cpu_id() usize {
    return get_system_value("mpidr_el1");
}

pub inline fn get_system_value(comptime name: []const u8) usize {
    return asm volatile ("mrs %[value], " ++ name
        : [value] "=r" (-> usize)
    );
}


