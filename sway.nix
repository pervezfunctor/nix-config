{ pkgs, ... }:
{
  nixosModule = {
    programs.sway.enable = true;
    environment.systemPackages = with pkgs; [
      swaylock-effects
      swayidle
    ];
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
  };

  homeModule = {
    home.file = {
      ".config/sway/config".source = ./config/sway/config;
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
