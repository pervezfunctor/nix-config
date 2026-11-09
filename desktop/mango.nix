# Mango compositor + its home config and the Noctalia shell.
{ inputs, pkgs, ... }:
{
  imports = [ inputs.mango.nixosModules.mango ];

  programs.mango.enable = true;

  environment.systemPackages = with pkgs; [
    swayidle
  ];

  home-manager.sharedModules = [
    inputs.mango.hmModules.mango
    ../home/noctalia.nix
    {
      systemd.user.targets.mango-session = {
        Unit = {
          Description = "mango compositor session";
          Requires = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
      };

      wayland.windowManager.mango = {
        enable = true;
      };

      home.file = {
        ".config/mango/config.conf" = {
          source = ../config/mango/config.conf;
          force = true;
        };
      };
    }
  ];
}
