{ pkgs, vars, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
      qemu.swtpm.enable = true;
      nss.enable = true;
      firewallBackend = "nftables";
      allowedBridges = [ "virbr0" ];
    };
  };
  services.libvirtd = {
    autoSnapshot.enable = true;
  };
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    distrobox
    dive
    dnsmasq
    guestfs-tools
    lazydocker
    libguestfs
    libosinfo
    looking-glass-client # zero-copy VM display client — pairs with qemu
                         # ivshmem-plain device for high-fps VM display when
                         # SPICE/GTK display paths bottleneck Venus/virgl.
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
