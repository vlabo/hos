// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const mmio = @import("mmio.zig");

const VIDEOCORE_MBOX    = mmio.BASE+0x0000B880;
const MBOX_READ         = VIDEOCORE_MBOX+0x0;
const MBOX_POLL         = VIDEOCORE_MBOX+0x10;
const MBOX_SENDER       = VIDEOCORE_MBOX+0x14;
const MBOX_STATUS       = VIDEOCORE_MBOX+0x18;
const MBOX_CONFIG       = VIDEOCORE_MBOX+0x1C;
const MBOX_WRITE        = VIDEOCORE_MBOX+0x20;
const MBOX_RESPONSE     = 0x80000000;
const MBOX_FULL         = 0x80000000;
const MBOX_EMPTY        = 0x40000000;


pub const MBOX_REQUEST  = 0;

// channels
pub const MBOX_CH_POWER =   0;
pub const MBOX_CH_FB    =   1;
pub const MBOX_CH_VUART =   2;
pub const MBOX_CH_VCHIQ =   3;
pub const MBOX_CH_LEDS  =   4;
pub const MBOX_CH_BTNS  =   5;
pub const MBOX_CH_TOUCH =   6;
pub const MBOX_CH_COUNT =   7;
pub const MBOX_CH_PROP  =   8;

// tags 
pub const MBOX_TAG_GETSERIAL =      0x10004;
pub const MBOX_TAG_SETCLKRATE =     0x38002;
pub const MBOX_TAG_LAST =           0;

pub export var data: [36]u32 align(16) = undefined; 

pub fn call(ch: u8) bool {
    var f: usize = 0xF;
    var add: usize = @intCast(usize, @ptrToInt(&data)) & ~f;
    var r: usize = add | (ch&0xF);
    //var r: c_uint = ((@bitCast(c_uint, @truncate(c_uint, (@intCast(c_ulong, @ptrToInt(&data))))) & @bitCast(c_uint, ~@as(c_int, 15))) | @bitCast(c_uint, (@bitCast(c_int, @as(c_uint, ch)) & @as(c_int, 15))));
    while((mmio.read(MBOX_STATUS) & MBOX_FULL) != 0) {
        asm volatile("nop");
    }
    mmio.write(MBOX_WRITE, @intCast(u32, r));
    while(true) {
        var a = true;
        while(a) {
            asm volatile("nop");
            a = (mmio.read(MBOX_STATUS) & MBOX_EMPTY) != 0;
        }
        if(r == mmio.read(MBOX_READ)) {
            return data[1] == MBOX_RESPONSE;
        }
    }

    return false;
}