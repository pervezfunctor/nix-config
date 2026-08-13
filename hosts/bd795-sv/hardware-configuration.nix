# Hand-written and verified against this disk (nvme0n1p3 btrfs + nvme0n1p7 FAT ESP).
# Boot/CPU/hostPlatform probed live via `nixos-generate-config --no-filesystems`.
# Do NOT regenerate with filesystems — nixos-generate-config mis-handles btrfs subvols.
{ config, lib, ... }:
{
  imports = [ ];

  # ── Filesystems (verified: nvme0n1p3 btrfs + nvme0n1p7 FAT ESP) ──────────
  # Root — btrfs subvol=nixos
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/700d2951-36a0-4e45-bed3-b290f2f5ac79";
    fsType = "btrfs";
    options = [
      "subvol=nixos"
      "compress=zstd"
      "noatime"
    ];
  };

  # Boot — btrfs subvol=boot_nixos on the SAME partition (kernels live here)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/700d2951-36a0-4e45-bed3-b290f2f5ac79";
    fsType = "btrfs";
    options = [
      "subvol=boot_nixos"
      "noatime"
    ];
  };

  # EFI System Partition — the FAT ESP (nvme0n1p7). /boot/efi, NOT /boot!
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/FE7D-CE78";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Home — btrfs subvol=nixos-home
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/700d2951-36a0-4e45-bed3-b290f2f5ac79";
    fsType = "btrfs";
    options = [
      "subvol=nixos-home"
      "compress=zstd"
      "noatime"
    ];
  };

  # --- libvirt VM image subvolumes (same btrfs partition, dedicated subvols) ---
  # qemu:///system — root-owned VM images, NoCoW (+C) directory.
  fileSystems."/var/lib/libvirt/images" = {
    device = "/dev/disk/by-uuid/700d2951-36a0-4e45-bed3-b290f2f5ac79";
    fsType = "btrfs";
    options = [
      "subvol=@libvirt"
      "compress=zstd:1"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  # qemu:///session — per-user VM images. NB: subvol name is @libvirt-home,
  # NOT @libvirt — a separate subvol so it can be owned by pervez and given its
  # own NoCoW +C flag independently of the system pool.
  fileSystems."/home/pervez/.local/share/libvirt/images" = {
    device = "/dev/disk/by-uuid/700d2951-36a0-4e45-bed3-b290f2f5ac79";
    fsType = "btrfs";
    options = [
      "subvol=@libvirt-home"
      "compress=zstd:1"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  # ── Hardware probe (from nixos-generate-config --no-filesystems) ──────────
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
