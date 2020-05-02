// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const AtomicOrder = @import("builtin").AtomicOrder;

pub const BASE = 0x3F000000;


pub fn write(reg: usize, data: u32) void {
    @fence(AtomicOrder.SeqCst);
    @intToPtr(*volatile u32, reg).* = data;
}

pub fn read(reg: usize) u32 {
    @fence(AtomicOrder.SeqCst);
    return @intToPtr(*volatile u32, reg).*; 
}