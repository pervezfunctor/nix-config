{ ... }:
{
  nixosModule = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # environment.sessionVariables = {
    #   XDG_CURRENT_DESKTOP = "Gnome";
    # };
  };

  homeModule = { };
}
