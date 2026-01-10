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
    gnome-themes-extra
    grim
    htop
    imagemagick
    imv
    inter
    kitty
    libcava
    libnotify
    libqalculate
    lm_sensors
    material-symbols
    matugen
    mpv
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    pywal
    pywalfox-native
    qt6ct
    rofi
    slurp
    smartmontools
    swappy
    swww
    waypaper
    wl-clip-persist
    wl-clipboard
    wlogout
    wlr-randr
    wlsunset
    # mako
    # noto-fonts
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif
    # noto-fonts-color-emoji
    # nwg-displays
    # nwg-displays
    # nwg-look
    # pamixer
    # papirus-icon-theme
    # pavucontrol
    # pulseaudio
    # udiskie
    # udisks2
  ];
}
