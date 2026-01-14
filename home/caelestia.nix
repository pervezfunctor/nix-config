{ inputs, ... }:
{
  imports = [
    inputs.caelestia.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      environment = [ ];
    };

    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Pictures/Wallpapers";
    };

    cli = {
      enable = true;
      settings = {
        theme.enableGtk = true;
        theme.enableIcons = true;
        theme.enableCursor = true;
      };
    };
  };
}
