{ pkgs, ... }:
{
  home = {
    file = {
      ".config/sway/config".source = ./conf/config;
    };
    packages = with pkgs; [
      swaylock
      swayidle
    ];
  };

  # wayland.windowManager.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;

  #   config = rec {
  #     modifier = "Mod4";
  #     terminal = "kitty";
  #     startup = [
  #       # Launch Firefox on start
  #       { command = "firefox"; }
  #     ];
  #   };
  # };
}
