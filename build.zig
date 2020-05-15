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
    
    const kernel = b.addExecutable("kernel", "src/arm.zig");
    kernel.setTarget(target);
    kernel.setLinkerScriptPath("linker.ld");
    kernel.setOutputDir("zig-cache");
    kernel.installRaw("kernel.img");

    kernel.setBuildMode(builtin.Mode.ReleaseFast);
    // kernel.strip = true;

    const qemu = b.step("qemu", "Run the OS in qemu");
    const upload = b.step("upload", "Upload the kernel");
    const dis = b.step("dis", "Disassemble");

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


    // const run_upload = b.addSystemCommand(upload_args.items);
    //const run_screen = b.addSystemCommand(screen_args.items);
    //run_screen.dependOn(&run_upload.step);
    

    var dis_args = std.ArrayList([]const u8).init(b.allocator);
    try dis_args.appendSlice(&[_][]const u8{
        "llvm-objdump",
        "-d",
        kernel.getOutputPath(),
    });

    var send_image_tool = b.addExecutable("send_image", undefined);

    send_image_tool.addCSourceFile("tools/uploader/raspbootcom.c", &[_][]const u8{"-std=c99"});
    send_image_tool.addIncludeDir("tools/uploader/");

    const run_send_image_tool = send_image_tool.run();
    run_send_image_tool.addArg("/dev/tty.SLAB_USBtoUART");
    run_send_image_tool.addArg("zig-cache/bin/kernel.img");

    upload.dependOn(&run_send_image_tool.step);

    const run_dis = b.addSystemCommand(dis_args.items);
    dis.dependOn(&run_dis.step);

    
    run_qemu.step.dependOn(&kernel.step);
    run_dis.step.dependOn(&kernel.step);
    b.default_step.dependOn(&kernel.step);
}
