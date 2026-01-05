{ pkgs, ... }:
{
  home.packages = with pkgs; [
    adw-gtk3
    adwaita-fonts
    adwaita-icon-theme
    app2unit
    bibata-cursors
    blueman
    bluez
    brightnessctl
    cliphist
    ddcutil
    fastfetch
    ffmpegthumbnailer
    fira-code
    fira-sans
    fish
    flameshot
    font-awesome
    gnome-keyring
    grim
    gvfs
    htop
    imagemagick
    imv
    kitty
    libcava
    libqalculate
    lm_sensors
    mako
    material-symbols
    matugen
    mpv
    nautilus
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    networkmanager
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nwg-displays
    nwg-look
    pamixer
    papirus-icon-theme
    pavucontrol
    # polkit
    # polkit_gnome
    pywal
    pywalfox-native
    qt6
    qt6ct
    rofi
    slurp
    smartmontools
    swappy
    swww
    udiskie
    udisks2
    wl-clip-persist
    wl-clipboard
    wlogout
    wlr-randr
    wlsunset
    # xdg-desktop-portal
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr
  ];
}
