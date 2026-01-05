{ pkgs, ... }:
{
  # Enable greetd as a display manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Disable getty autologin since we're using greetd
  services.getty.autologinUser = null;

  environment.systemPackages = with pkgs; [ tuigreet ];
}
