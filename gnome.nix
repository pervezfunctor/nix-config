{ pkgs, ... }:
{
  nixosModule = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.gnome-keyring.enable = true;
    programs.gnome-keyring.secrets = true;
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.coverflow-alt-tab
      gnomeExtensions.just-perfection
      gnomeExtensions.paperwm
      gnomeExtensions.undecorate
      gnomeExtensions.user-themes
      gnomeExtensions.vitals
      gnomeExtensions.switcher
      gnome-tweaks
    ];

    # To disable installing GNOME's suite of applications
    # and only be left with GNOME shell.
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    # environment.sessionVariables = {
    #   XDG_CURRENT_DESKTOP = "Gnome";
    # };
  };

  homeModule = { };
}
