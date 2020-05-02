// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const arm = @import("arm.zig");

pub fn wait_for_cicles(cicles: usize) void {
    var i: usize = cicles;
    while(i > 0) {
        i -= 1;
        arm.nop();
    }
} 