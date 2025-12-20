{ inputs, pkgs, ... }:
{
  nixosModule = {
    programs.mango.enable = true;

    environment.systemPackages = with pkgs; [
      rofi
      hypridle
    ];
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
      ".config/mango/config.conf".source = ./conf/config.conf;
    };
  };
}
