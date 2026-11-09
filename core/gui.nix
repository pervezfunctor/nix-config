# Graphical-session base shared by every desktop host. CLI-only hosts import
# core/cli.nix without this module.
{ pkgs, vars, ... }:
{
  hardware.graphics = {
    enable = true;
  };
  # environment.variables = {
  #   VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";
  # };

  hardware.bluetooth.enable = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
    # Don't set TERM here: it would override every login session (tty, ssh,
    # root) via pam_env. Terminal emulators set TERM themselves.
    TERMINAL = "kitty";
  };

  services.power-profiles-daemon.enable = true; # or services.tuned.enable for laptop
  services.upower.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # thumbnailer for nautilus/thunar
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.flatpak.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  fonts = {
    packages = with pkgs; [
      fira-code
      font-awesome
      inter
      inter-nerdfont
      nerd-fonts.jetbrains-mono
      nerd-fonts.monaspace
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      # defaultFonts = {
      #   serif = [ "Noto Serif" ];
      #   sansSerif = [
      #     "Inter"
      #     "Noto Sans"
      #   ];
      # };
    };
  };

  users.extraGroups.video.members = [ vars.username ];

  environment.systemPackages = with pkgs; [
    udisks2
    udiskie
    wl-clipboard
    libxcb
    libxcb-wm
    adwaita-fonts
    adwaita-icon-theme
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    virglrenderer
    mesa
    mesa-demos
  ];

  home-manager.sharedModules = [
    ../home/gui-base.nix
    ../home/dev-gui.nix
  ];
}
