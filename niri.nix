{ pkgs, ... }:
{
  nixosModule = {
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [
      fuzzel
      swayidle
    ];
  };

  homeModule = {
    home.file = {
      ".config/niri/config.kdl".source = ./config/niri/config.kdl;
    };
  };
}
