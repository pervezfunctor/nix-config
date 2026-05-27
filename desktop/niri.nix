{ pkgs, ... }:
{
  nixosModule = {
    programs.niri = {
      enable = true;
      useNautilus = true;
    };

    environment.systemPackages = with pkgs; [
      accountsservice
      alacritty
      cups-pk-helper
      fuzzel
      # swayidle
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
