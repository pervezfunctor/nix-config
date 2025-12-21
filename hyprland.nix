{ pkgs, ... }:
{
  nixosModule = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };
    programs.hypridle.enable = true;

    environment.systemPackages = with pkgs; [
      mako
      hyprcursor
      hyprlauncher
      hyprlock
      xdg-desktop-portal-hyprland
      hyprsysteminfo
      hyprsunset
      hyprpolkitagent
      hyprland-qt-support
      hyprpwcenter
      hyprpaper
      hypridle
    ];
  };

  homeModule = {
    home.file = {
      ".config/hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;
    };
  };
}
