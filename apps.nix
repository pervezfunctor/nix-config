{ pkgs, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    qbittorrent
    telegram-desktop
    zoom-us
  ];
}
