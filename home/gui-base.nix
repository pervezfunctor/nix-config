# Graphical-session home config: terminal emulator + cursor theme.
{ pkgs, ... }:

{
  home.pointerCursor = {
    # gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 32;
  };

  home.packages = with pkgs; [
    kitty
  ];

  home.file = {
    ".config/kitty/kitty.conf" = {
      source = ../config/kitty/kitty.conf;
      force = true;
    };
  };
}
