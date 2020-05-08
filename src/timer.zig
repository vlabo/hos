// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const arm = @import("arm.zig");
const mmio = @import("io/mmio.zig");

const SYSTMR_LO = (mmio.BASE+0x00003004);
const SYSTMR_HI = (mmio.BASE+0x00003008);

pub fn wait_for_cicles(cicles: usize) void {
    var i: usize = cicles;
    while(i > 0) {
        i -= 1;
        arm.nop();
    }
} 

pub fn wait_msec(msec: u32) void {
    var freq: usize =  asm volatile ("mrs x1, cntfrq_el0" 
                : [ret] "={x1}" (-> usize));
   

    var start_time: usize = asm volatile ("mrs x2, cntpct_el0"
                  : [ret] "={x2}" (-> usize));

    var end_time = start_time + ((freq/1000) * msec);

    while(true) {
        var current_time = asm volatile ("mrs x3, cntpct_el0"
                  : [ret] "={x3}" (-> usize));

        if(current_time >= end_time) {
            break;
        }
    }
}
