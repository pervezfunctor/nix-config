{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    config = {
      common = {
        #
      };
    };
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
}
