#! /usr/bin/env nu

# Extra args are passed to qemu, e.g. `nu vm-venus.nu nixos -snapshot`.
def --wrapped main [image: string, ...extra: string] {
  let vars_file = $"($env.HOME)/.config/libvirt/qemu/nvram/($image)_VARS.fd"
  let disk_file = $"($env.HOME)/.local/share/libvirt/images/images/($image).qcow2"

  with-env { GDK_BACKEND: wayland} {
    let args = [
      "-enable-kvm"
      "-M" "q35"
      "-smp" "8"
      "-m" "32G"
      "-cpu" "host"
      "-net" "nic,model=virtio"
      "-net" "user,hostfwd=tcp::2222-:22"
      "-device" "virtio-sound-pci,audiodev=my_audiodev"
      "-audiodev" "pipewire,id=my_audiodev"
      "-device" "virtio-vga-gl,hostmem=4G,blob=true,venus=true"
      "-vga" "none"
      "-display" "gtk,gl=on,grab-on-hover=on"
      "-usb"
      "-device" "usb-tablet"
      "-object" "memory-backend-memfd,id=mem1,size=32G"
      "-machine" "memory-backend=mem1"
      "-drive" "if=pflash,format=raw,readonly=on,file=/run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd"
      "-drive" $"if=pflash,format=raw,file=($vars_file)"
      "-drive" $"file=($disk_file)"
    ]

    qemu-system-x86_64 ...$args ...$extra
  }
}
