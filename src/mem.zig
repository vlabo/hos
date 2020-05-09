extern var __bss_start: u8;
extern var __bss_end: u8;

pub var heap: [1024 * 4]u8 = undefined;

pub fn init() void {
    // zero out bss section
    @memset(@as(*volatile [1]u8, &__bss_start), 0, @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start));
}


