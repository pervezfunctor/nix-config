# Host: nixos (physical machine, btrfs subvols + EFI GRUB + GNOME)
# Mirrors the repo's other hosts but swaps GRUB in for systemd-boot because
# /boot is a btrfs subvol (boot_nixos) and the FAT ESP is at /boot/efi.
# systemd-boot CANNOT read a btrfs /boot — GRUB with --modules=btrfs is mandatory.
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "bd795-sv";
  hardware.graphics.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ESP is nvme0n1p7, NOT /boot
    };
    grub = {
      enable = true;
      device = "nodev"; # mandatory for UEFI
      efiSupport = true;
      efiInstallAsRemovable = false;
      useOSProber = true;
      configurationLimit = 20;
      copyKernels = true; # different st_dev — kernels copied to ESP-reachable store
      extraGrubInstallArgs = [ "--modules=btrfs" ];

      extraEntries = ''
        menuentry "Fedora KDE" {
          search --no-floppy --fs-uuid --set=root 00CE-B75C
          chainloader /EFI/fedora-kde/shimx64.efi
        }
        menuentry "Fedora GNOME" {
          search --no-floppy --fs-uuid --set=root 0401-8797
          chainloader /EFI/fedora-gnome/shimx64.efi
        }
        menuentry "CachyOS (Limine)" {
          search --no-floppy --fs-uuid --set=root 83E0-42C5
          chainloader /EFI/limine/limine_x64.efi
        }
      '';
    };
  };
  boot.supportedFilesystems = [ "btrfs" ];

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.pervez = {
    isNormalUser = true;
    description = "Pervez Iqbal";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs.firefox.enable = true;

  # lsattr/chattr — needed to inspect/set NoCoW (+C) on btrfs subvols & VM images.
  # Also pull in the shared sys.nix toolset (pciutils/usbutils for lspci/lsusb
  # to verify VFIO binding, gnupg, yubikey stack, etc.).
  environment.systemPackages = [ pkgs.e2fsprogs ] ++ (import ../../core/sys.nix { inherit pkgs; });

  # btrfs auto-scrub (optional, nice for a btrfs root)
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

  services.smartd.enable = true;
  services.openssh.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true;
  services.pulseaudio.enable = false;
}
