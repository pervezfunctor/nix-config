{ pkgs, ... }:
{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    cliphist
    wl-clipboard
    papirus-icon-theme
    pywalfox-native
  ];
}
