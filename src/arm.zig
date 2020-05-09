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
    return asm volatile ("mrs x1, mpidr_el1"
        : [ret] "={x1}" (-> usize)
    );
}


