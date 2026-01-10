{ inputs, ... }:
{
  imports = [
    inputs.caelestia.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false;
      environment = [ ];
    };

    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Pictures/wallpapers";
    };

    cli = {
      enable = false;
      settings = {
        theme.enableGtk = true;
        theme.enableIcons = true;
        theme.enableCursor = true;
      };
    };
  };
}
