const mmio = @import("arm/io/mmio.zig");

pub const PM_RSTC = (mmio.BASE + 0x0010001c);
pub const PM_RSTS = (mmio.BASE + 0x00100020);
pub const PM_WDOG = (mmio.BASE + 0x00100024);
pub const PM_WDOG_MAGIC = 0x5a000000;
pub const PM_RSTC_FULLRST = 0x00000020;

pub fn reset() void {
    // trigger a restart by instructing the GPU to boot from partition 0
    var r = mmio.read(PM_RSTS);
    var a: u32 = 0xfffffaaa;
    r &= ~a;
    mmio.write(PM_RSTS, PM_WDOG_MAGIC | r); // boot from partition 0
    mmio.write(PM_WDOG, PM_WDOG_MAGIC | 10);
    mmio.write(PM_RSTC, PM_WDOG_MAGIC | PM_RSTC_FULLRST);
}
