{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dankMaterialShell.default
  ];

  programs.dankMaterialShell = {
    enable = true;

    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableClipboard = true; # Clipboard history manager
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    # enableVPN = true; # VPN management widget
    # enableAudioWavelength = true; # Audio visualizer (cava)
    # enableCalendarEvents = true; # Calendar integration (khal)

    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
}
