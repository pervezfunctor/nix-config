{ pkgs, ... }:
{
  nixosModule = {
    programs.niri = {
      enable = true;
      useNautilus = true;
    };

    environment.systemPackages = with pkgs; [
      alacritty
      fuzzel
      swayidle
    ];

  };

  homeModule = {
    home.file = {
      ".config/niri/config.kdl" = {
        source = ../config/niri/config.kdl;
        force = true;
      };
    };
  };
}
