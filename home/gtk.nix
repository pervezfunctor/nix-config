{ pkgs, ... }:
{
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

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = with pkgs.gnomeExtensions; [
        open-bar.extensionUuid
        paperwm.extensionUuid
        search-light.extensionUuid
        switcher.extensionUuid
        user-themes.extensionUuid
        windowsNavigator.extensionUuid
        # switch-workspace.extensionUuid
        # focus-follows-workspace.extensionUuid
      ];
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3";
      color-scheme = "prefer-dark";
      # accent-color = "teal";
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

  #     theme = {
  #       package = pkgs.flat-remix-gtk;
  #       name = "Flat-Remix-GTK-Grey-Darkest";
  #     };

  #     iconTheme = {
  #       package = pkgs.adwaita-icon-theme;
  #       name = "Adwaita";
  #     };

  #     font = {
  #       name = "Sans";
  #       size = 11;
  #     };

  # qt = {
  #   enable = true;
  #   platformTheme = "qtct";
  #   style = "kvantum";
  # };

  # xdg.configFile = {
  #   "Kvantum/ArcDark".source = "${pkgs.arc-kde-theme}/share/Kvantum/ArcDark";
  #   "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=ArcDark";
  # };
}
