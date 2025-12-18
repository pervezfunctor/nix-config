{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = false;
  };

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    font-awesome
    dunst
    hyprcursor
    hypridle
    hyprlock
    hyprpaper
    kitty
    networkmanagerapplet
    rofi
    swaynotificationcenter
    waybar
    wl-clipboard
    wlogout
  ];
}
