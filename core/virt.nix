{ config, pkgs, vars, ... }:
{
  # Looking Glass: kvmfr module provides /dev/kvmfr0, the DMA-capable IVSHMEM
  # backend shared with the win11 VM (size must match the VM's qemu:commandline
  # memory-backend-file size: 128M). The udev rule grants the client access
  # without any /dev/shm chmod hacks.
  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  boot.kernelModules = [ "kvmfr" ];
  boot.extraModprobeConfig = ''
    options kvmfr static_size_mb=128
  '';

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
      qemu.swtpm.enable = true;
      nss.enable = true;
      firewallBackend = "nftables";
      allowedBridges = [ "virbr0" ];
      # QEMU's device cgroup denies /dev/kvmfr0 unless explicitly listed,
      # blocking the Looking Glass memory backend ("Operation not permitted")
      qemu.verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/kvmfr0"
        ]
      '';
    };
  };
  services.libvirtd = {
    autoSnapshot.enable = true;
  };
  programs.virt-manager.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    distrobox
    dive
    dnsmasq
    guestfs-tools
    lazydocker
    libguestfs
    libosinfo
    looking-glass-client
    swtpm
    virglrenderer
    virt-manager
    virt-viewer
    virtiofsd
    xorriso
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [
    "virbr0"
  ];

  users.extraGroups.docker.members = [ vars.username ];
  users.extraGroups.libvirtd.members = [ vars.username ];
  users.extraGroups.kvm.members = [ vars.username ];
}
