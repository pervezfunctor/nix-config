# Niri compositor + its home config and the DMS shell.
{ pkgs, ... }:
{
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

  home-manager.sharedModules = [
    ../home/dms.nix
    {
      home.file = {
        ".config/niri/config.kdl" = {
          source = ../config/niri/config.kdl;
          force = true;
        };
      };
    }
  ];
}
