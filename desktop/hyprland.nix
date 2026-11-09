# Hyprland compositor + the Caelestia shell.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = false;
  };

  environment.systemPackages = with pkgs; [
    hyprcursor
    hyprlauncher
    hyprlock
    hyprsysteminfo
    hyprsunset
    hyprpolkitagent
    hyprland-qt-support
    hyprpwcenter
    hyprpaper
    hypridle
  ];

  home-manager.sharedModules = [
    ../home/caelestia.nix
    # {
    #   home.file = {
    #     ".config/hypr/hyprland.conf" = {
    #       source = ../config/hypr/hyprland.conf;
    #       force = true;
    #     };
    #   };
    # }
  ];
}
