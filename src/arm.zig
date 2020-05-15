// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const main = @import("main.zig");
const cpu = @import("cpu.zig").Current;

/// Entry point
export fn _start() noreturn {
    if(cpu.get_cpu_id() & 0x3 != 0) {
        cpu.wfi();
    }
    asm volatile (
        \\ ldr     x1, =_start
        \\ mov     sp, x1
    );
    main.main();
}

