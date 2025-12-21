{ pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XDG_CURRENT_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    adw-gtk3
    adwaita-fonts
    adwaita-icon-theme
    cliphist
    fira-code
    fira-sans
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    papirus-icon-theme
    pywal
    pywalfox-native
    nautilus
    wl-clipboard
  ];
}
