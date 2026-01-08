{ pkgs, vars, ... }:
{
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "gtk3";
    # QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;
  xdg.portal.enable = true;
  # services.udisks2.enable = true;

  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];

  users.users.${vars.username}.shell = pkgs.zsh;

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
    fira-code
    fira-sans
    flameshot
    font-awesome
    ghostty
    gnome-keyring
    grim
    gvfs
    htop
    imagemagick
    imv
    kitty
    lm_sensors
    mako
    matugen
    mpv
    nautilus
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nwg-displays
    nwg-look
    pamixer
    papirus-icon-theme
    pavucontrol
    pywal
    pywalfox-native
    rofi
    slurp
    smartmontools
    swww
    udiskie
    udisks2
    wl-clip-persist
    wl-clipboard
    wlogout
    wlr-randr
    wlsunset
    # polkit
    # polkit_gnome
    # xdg-desktop-portal
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr
  ];
}
