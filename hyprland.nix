{ pkgs, ... }:
{
  nixosModule = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };

    # environment.sessionVariables = {
    #   XDG_CURRENT_DESKTOP = "Hyprland";
    #   XDG_SESSION_TYPE = "wayland";
    # };

    environment.systemPackages = with pkgs; [
      # hyprcursor
      # hyprlauncher
      # hyprlock
      # xdg-desktop-portal-hyprland
      # hyprsysteminfo
      # hyprsunset
      # hyprpolkitagent
      # hyprland-qt-support
      # hyprpwcenter
      # hyprpaper
      hypridle
    ];
  };

  homeModule = {
    home.file = {
      ".config/hypr/hyprland.conf" = {
        source = ./config/hypr/hyprland.conf;
        force = true;
      };
    };
  };
}
