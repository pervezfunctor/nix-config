{ pkgs, ... }:
{
  nixosModule = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };

    environment.systemPackages = with pkgs; [
      mako
      hyprcursor
      hypridle
      hyprpaper
    ];
  };

  homeModule = {
    home.file = {
      ".config/hypr/hyprland.conf".source = ./conf/hyprland.conf;
    };
  };
}
