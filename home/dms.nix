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

    # systemd = {
    #   enable = true; # Systemd service for auto-start
    #   restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    # };
  };
}
