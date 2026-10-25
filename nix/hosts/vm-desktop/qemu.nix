{
  lib,
  modulesPath,
  pkgsUnstable,
  ...
}:
let
  memSize = 5000;
in
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  services = {
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;
  };

  programs.sway = {
    package = lib.mkForce pkgsUnstable.sway;
  };

  disko.memSize = memSize;

  virtualisation = {
    cores = 8;
    memorySize = memSize;

    # Three context types are available for the virtio-gpu device:
    #
    # ## virgl (OpenGL)
    # - Guest Side: The Mesa Gallium driver virgl implements OpenGL and OpenGL ES.
    #               It encodes Gallium state, draw calls and shaders in TGSI form into a command stream.
    # - Host Side: virglrenderer decodes the stream and re-issues
    #              It as host OpenGL calls. It translates TGSI shaders to GLSL,
    #              and the host driver compiles them again.
    # - Consequences:
    #   - The guest gets OpenGL/GLES only,
    #     limited to what the protocol implements (about GL 4.3 / GLES 3.2), and no Vulkan.
    #   - Every command passes through a decode-and-translate step,
    #     and synchronous operations (reading pixels back, waiting on fences) cost round trips between guest and host.
    #   - The guest driver does not depend on which host GPU you have.
    # - How to recognise it: glxinfo -B in the guest shows a renderer string of the form virgl (<host GPU>).
    #
    # ## Venus (Vulkan)
    # - Guest Side: The Mesa Vulkan driver venus serialises Vulkan API calls close to 1:1.
    #               The encoder is generated from the Vulkan XML registry.
    # - Host Side: virglrenderer executes these calls on the host Vulkan driver (for AMD, RADV).
    #              Shaders are SPIR-V and are passed through without translation.
    # - Memory: Vulkan lets the application map GPU memory directly. Venus therefore needs:
    #   - blob resources (blob=on): buffers allocated by the host and mapped into the guest;
    #   - a host-memory window (hostmem=<size>): a PCI BAR region through which the guest maps that memory.
    # - Consequences:
    #   - The guest gets Vulkan. OpenGL in the guest then runs through Zink,
    #                 Mesa's OpenGL implementation on top of Vulkan.
    #   - The guest driver still does not depend on the host GPU model.
    #     The host Vulkan driver must support external memory (dma-buf) and DRM format modifiers.
    #
    # ## DRM native context (Direct Rendering Manager)
    # - Guest Side: The guest runs the native Mesa driver for the host's GPU.
    #               For AMD these are radeonsi (OpenGL) and RADV (Vulkan),
    #               with Mesa's amdgpu virtio backend. For Qualcomm they are freedreno and turnip.
    # - What is Forwarded: Not API calls, but the operations the driver would normally send to the kernel
    #                      through /dev/dri/renderD128: buffer allocation,
    #                      submission of command buffers that are already compiled for the GPU, and fences.
    # - Host Side: virglrenderer passes these operations to the host kernel DRM driver (amdgpu),
    #              and the GPU executes the guest's command buffers directly.
    # - Advantages: performance close to native, and the full OpenGL and Vulkan feature set of the native driver.
    # - Costs:
    #   - The guest needs a driver for the exact host GPU family, so the VM image depends on the host hardware.
    #   - The guest's command buffers reach the host kernel driver and the GPU with less filtering.
    #     Isolation relies on the GPU's per-context address spaces, which is a larger attack
    #     surface than API-level protocols.
    # - Memory: it needs blob resources and hostmem, like Venus.
    #
    qemu = {
      package = pkgsUnstable.qemu;
      enableSharedMemory = true;
      options = [
        # "-device virtio-vga-gl,hostmem=8G"
        # "-display gtk,gl=on"
        # "-device usb-tablet"
        # "-spice port=5900,addr=127.0.0.1,disable-ticketing=on"
        # "-device qxl"
        # "-vga qxl"
      ];
    };
  };
}
