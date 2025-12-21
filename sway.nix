{ pkgs, ... }:
{
  nixosModule = {
    programs.sway.enable = true;
    environment.systemPackages = with pkgs; [
      swaylock
      swayidle
    ];
  };

  homeModule = {
    home.file = {
      ".config/sway/config".source = ./conf/config;
    };
  };
}

# wayland.windowManager.sway = {
#   enable = true;
#   wrapperFeatures.gtk = true;

#   config = rec {
#     modifier = "Mod4";
#     terminal = "ghostty";
#     startup = [
#       # Launch Firefox on start
#       { command = "firefox"; }
#     ];
#   };
# };
