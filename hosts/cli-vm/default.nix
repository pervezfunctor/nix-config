# Headless QEMU guest: CLI tooling only, no graphics stack.
# Build and run:  nix run .#cli-vm-vm   (console on the terminal via serial)
{
  lib,
  modulesPath,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  networking.hostName = lib.mkDefault "cli-vm";
  networking.networkmanager.enable = true;

  # Virtio devices need no blobs; drops ~850 MB of linux-firmware.
  hardware.enableRedistributableFirmware = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  users.users.${vars.username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
      memorySize = 4096;
      cores = 4;
      diskSize = 20480;
    };
    # Throwaway login for the `nix run .#cli-vm-vm` image only.
    users.users.${vars.username}.initialPassword = "nixos";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
}
