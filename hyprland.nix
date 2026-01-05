{ pkgs, ... }:
{
  nixosModule = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
    };
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
      rofi
    ];
  };

  homeModule = {
    home.file = {
      ".config/hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;
    };
  };
}
