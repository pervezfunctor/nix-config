{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    # This might not work as intended, as it might start with niri/hyprland too.
    systemd.enable = true;
  };

  systemd.user.services.noctalia-shell = {
    Install = {
      WantedBy = [ "mango-session.target" ];
    };
  };
}
