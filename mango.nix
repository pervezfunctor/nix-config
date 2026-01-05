{ inputs, pkgs, ... }:
{
  nixosModule = {
    programs.mango.enable = true;

    environment.systemPackages = with pkgs; [
      swayidle
    ];
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "mango";
  };

  homeModule = {
    imports = [
      inputs.mango.hmModules.mango
    ];

    wayland.windowManager.mango = {
      enable = true;
      # settings = ''
      #   # see config.conf
      # '';
      # autostart_sh = ''
      #   # see autostart.sh
      #   # Note: here no need to add shebang
      # '';
    };

    home.file = {
      ".config/mango/config.conf".source = ./config/mango/config.conf;
    };
  };
}
