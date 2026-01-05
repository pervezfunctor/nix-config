{ pkgs, ... }:
{
  nixosModule = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Gnome";
    };
  };

  homeModule = {
    gtk = {
      enable = true;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-overlay-scrolling = false;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-overlay-scrolling = false;
      };
    };

    home.packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      coverflow-alt-tab
      just-perfection
      paperwm
      undecorate
      user-themes
      vitals
      switcher
    ];

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;

        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          coverflow-alt-tab.extensionUuid
          just-perfection.extensionUuid
          paperwm.extensionUuid
          undecorate.extensionUuid
          user-themes.extensionUuid
          vitals.extensionUuid
          switcher.extensionUuid
        ];
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "caps:ctrl_modifier" ];
      };

      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      "org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark";
        accent-color = "teal";
        color-scheme = "prefer-dark";
        gtk-key-theme = "Emacs";
        monospace-font-name = "JetbrainsMono Nerd Font 11";
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        center-new-windows = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
      };
    };
  };
}
