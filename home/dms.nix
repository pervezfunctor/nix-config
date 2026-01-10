{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dankMaterialShell.default
  ];

  programs.dankMaterialShell = {
    enable = true;

    enableSystemMonitoring = true;
    enableClipboard = true;
    enableDynamicTheming = true;

    systemd = {
      enable = false;
      restartIfChanged = true;
    };
  };
}
