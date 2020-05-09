// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

/// https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
const mmio = @import("mmio.zig");
const arm = @import("../arm.zig");

const VideocoreMbox = struct {
    read: u32,
    reserved1: [12]u8,
    poll: u32,
    sender: u32,
    status: u32,
    config: u32,
    write: u32,

    fn is_empty(self: *volatile VideocoreMbox) bool {
        return self.status & 0x40000000 != 0;
    }

    fn is_full(self: *volatile VideocoreMbox) bool {
        return self.status & 0x80000000 != 0;
    }
};

pub const MBOX_REQUEST = 0;

pub const Channel = enum(u8) {
    power = 0,
    fb = 1,
    vuart = 2,
    vchiq = 3,
    leds = 4,
    btns = 5,
    touch = 6,
    count = 7,
    prop = 8,
};

pub const Tag = enum(u32) {
    get_serial = 0x10004,
    set_clk_rate = 0x38002,
    last = 0,

    pub fn to_int(self: Tag) u32 {
        return @enumToInt(self);
    }
};

pub export var data: [36]u32 align(16) = undefined;

var mbox align(32) = @intToPtr(*volatile VideocoreMbox, mmio.VIDEO_CORE_MAILBOX);

pub fn call(channel: Channel) bool {
    var f: usize = 0xF;
    var add: usize = @intCast(usize, @ptrToInt(&data)) & ~f;
    var r: usize = add | (@enumToInt(channel) & 0xF);

    while (mbox.is_full()) {
        arm.nop();
    }

    mbox.write = @intCast(u32, r);

    while (true) {
        var a = true;
        while (mbox.is_empty()) {
            arm.nop();
        }

        if (r == mbox.read) {
            return data[1] == 0x80000000;
        }
    }

    return false;
}

test "mbox registers" {
    const expectEqual = @import("std").testing.expectEqual;
    var registers = @intToPtr(*VideocoreMbox, 0x10000000);
    expectEqual(@ptrToInt(&registers.read), 0x10000000);
    expectEqual(@ptrToInt(&registers.poll), 0x10000010);
    expectEqual(@ptrToInt(&registers.sender), 0x10000014);
    expectEqual(@ptrToInt(&registers.status), 0x10000018);
    expectEqual(@ptrToInt(&registers.config), 0x1000001C);
    expectEqual(@ptrToInt(&registers.write), 0x10000020);
}
