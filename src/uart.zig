// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const gpio = @import("gpio.zig");
const mmio = @import("mmio.zig");
const mbox = @import("mbox.zig");

// PL011 UART registers
pub const UART0_DR        = mmio.BASE+0x00201000;
pub const UART0_FR        = mmio.BASE+0x00201018;
pub const UART0_IBRD      = mmio.BASE+0x00201024;
pub const UART0_FBRD      = mmio.BASE+0x00201028;
pub const UART0_LCRH      = mmio.BASE+0x0020102C;
pub const UART0_CR        = mmio.BASE+0x00201030;
pub const UART0_IMSC      = mmio.BASE+0x00201038;
pub const UART0_ICR       = mmio.BASE+0x00201044;

pub fn init() void {

    mmio.write(UART0_CR, 0);    // turn off UART0

    // set up clock for consistent divisor values 
    mbox.data[0] = 9*4;
    mbox.data[1] = mbox.MBOX_REQUEST;
    mbox.data[2] = mbox.MBOX_TAG_SETCLKRATE; // set clock rate
    mbox.data[3] = 12;
    mbox.data[4] = 8;
    mbox.data[5] = 2;           // UART clock
    mbox.data[6] = 4000000;     // 4Mhz
    mbox.data[7] = 0;           // clear turbo
    mbox.data[8] = mbox.MBOX_TAG_LAST;
    var success = mbox.call(mbox.MBOX_CH_PROP);

    var pins = [_]u8{14, 15};
    gpio.set_pins_mode(&pins, gpio.Mode.alt0);

    mmio.write(UART0_ICR, 0x7FF);    // clear interrupts
    mmio.write(UART0_IBRD, 2);       // 115200 baud
    mmio.write(UART0_FBRD, 0xB);
    mmio.write(UART0_LCRH, 0b11<<5); // 8n1
    mmio.write(UART0_CR, 0x301);     // enable Tx, Rx, FIFO
}


pub fn qsend(c: u8) void {
    mmio.write(0x3F201000, c);
}

pub fn qputs(string: []const u8) void {
     for (string) |value| {
        if(value == '\n')
            qsend('\r');
        qsend(value);
    }
}

pub fn send(c: u8) void {
    while ((mmio.read(UART0_FR) & 0x20) != 0) {
        asm volatile("nop");
    }
    mmio.write(UART0_DR, c);
}

pub fn uart_hex(d: u32) void {
    var n: u32 = 0;
    var c: i32 = 28;
    while(c>=0) : (c -= 4) {
        // get highest tetrad
        n=(d >> @intCast(u5, c))&0xF;
        // 0-9 => '0'-'9', 10-15 => 'A'-'F'
        var v : u32 = if (n>9) 0x37 else 0x30;
        n += v;
        qsend(@intCast(u8, n));
    }
}


pub fn puts(string: []const u8) void {
    for (string) |value| {
        if(value == '\n')
            send('\r');
        send(value);
    }
}

pub fn getc() u8 {
    while ((mmio.read(UART0_FR) & 0x10) != 0) {
        asm volatile("nop");
    }

    var c: u8 = @intCast(u8, mmio.read(UART0_DR));
    if(c == '\r') {
        return '\n';
    }

    return c;
}