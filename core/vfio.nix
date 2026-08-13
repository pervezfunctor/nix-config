# Host-side VFIO plumbing for GPU passthrough on bd795-sv.
#
# Mirrors the Fedora GRUB/dracut setup from the gist, but in NixOS terms:
#   - kernel cmdline: amd_iommu=on iommu=pt
#   - nouveau blacklisted so it never binds the NVIDIA dGPU
#   - vfio-pci claims the dGPU, its HDMI audio, and the USB controller by ID
#   - vfio drivers loaded early in the initrd so binding wins the race
#
# Hardware (from the gist):
#   01:00.0 10de:2489  NVIDIA RTX 3060 Ti LHR (VGA)   — IOMMU Group 13
#   01:00.1 10de:228b  NVIDIA HDMI audio              — IOMMU Group 13
#   05:00.3 1022:15b6  AMD Raphael xHCI USB controller — IOMMU Group 20
# The host keeps its display on the AMD Raphael iGPU (05:00.0), so no
# host-display-unbind hooks are needed.
{ pkgs, ... }:
{
  boot.kernelParams = [
    "iommu=pt"
  ];

  boot.initrd.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];

  boot.extraModprobeConfig = ''
    options vfio_pci ids=10de:2489,10de:228b,1022:15b6
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
  ];

  environment.systemPackages = with pkgs; [
    OVMF
  ];
}
