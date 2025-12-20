{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qbittorrent
    telegram-desktop
    zoom-us
  ];
}
