const std = @import("std");
const Builder = std.build.Builder;
const builtin = @import("builtin");
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) !void {
    const target = CrossTarget{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .cpu_model = .{ .explicit = &std.Target.aarch64.cpu.cortex_a53 },
    };
    
    const kernel = b.addExecutable("kernel", "src/main.zig");
    kernel.addAssemblyFile("src/start.S");
    kernel.setTarget(target);
    kernel.setLinkerScriptPath("linker.ld");
    kernel.setOutputDir("zig-cache");
    kernel.installRaw("kernel.img");

    kernel.setBuildMode(builtin.Mode.ReleaseFast);
    // kernel.strip = true;

    const qemu = b.step("qemu", "Run the OS in qemu");
    const upload = b.step("upload", "Upload the kernel");

    var qemu_args = std.ArrayList([]const u8).init(b.allocator);
    try qemu_args.appendSlice(&[_][]const u8{
        "qemu-system-aarch64",
        "-kernel",
        kernel.getOutputPath(),
        "-m",
        "256",
        "-M",
        "raspi3",
        "-serial",
        "stdio",
        "-display",
        "none",
    });
    const run_qemu = b.addSystemCommand(qemu_args.items);
    qemu.dependOn(&run_qemu.step);


    var upload_args = std.ArrayList([]const u8).init(b.allocator);
    try upload_args.appendSlice(&[_][]const u8{
        "kernel_uploader",
        "/dev/tty.SLAB_USBtoUART",
        "./zig-cache/bin/kernel.img",
    });

    const run_upload = b.addSystemCommand(upload_args.items);
    upload.dependOn(&run_upload.step);



    run_qemu.step.dependOn(&kernel.step);
    run_upload.step.dependOn(&kernel.step);
    b.default_step.dependOn(&kernel.step);
}
