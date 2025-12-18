{ pkgs, ... }:
let
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      # binds = with config.lib.niri.actions; {
      # binds = {
      #   "Mod+L".action.spawn = noctalia "lockScreen toggle";
      #   "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
      #   "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
      #   "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
      #   "Mod+Space".action.spawn = [
      #     "noctalia-shell"
      #     "ipc"
      #     "call"
      #     "launcher"
      #     "toggle" # ✅
      #   ];
      #   "Mod+P".action.spawn = "noctalia-shell ipc call sessionMenu toggle"; # ❌
      # };
      bar = {
        density = "compact";
        position = "right";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
    };
  };
}
