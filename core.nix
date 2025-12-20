{ pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Adwaita";
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    cliphist
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    papirus-icon-theme
    pywalfox-native
    wl-clipboard
  ];
}
