{ pkgs, vars, ... }:
{
  # hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "gtk3";
    # QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };

  services.dbus.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.${vars.username}.shell = pkgs.zsh;

  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
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
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [
        "Inter"
        "Noto Sans"
      ];
    };
  };

  users.extraGroups.video.members = [ vars.username ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    adwaita-fonts
    adwaita-icon-theme
    bibata-cursors
    blueman
    bluez
    brightnessctl
    cliphist
    fastfetch
    ffmpegthumbnailer
    flameshot
    gnome-themes-extra
    grim
    imagemagick
    imv
    libnotify
    lm_sensors
    matugen
    mpv
    nwg-displays
    nwg-look
    pamixer
    papirus-icon-theme
    pavucontrol
    pulseaudio
    pywal
    pywalfox-native
    rofi
    slurp
    smartmontools
    swww
    udiskie
    waypaper
    wl-clip-persist
    wl-clipboard
    wlogout
    wlr-randr
    wlsunset
  ];
}
