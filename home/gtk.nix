{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dconf-editor
  ];

  # programs.gnome-keyring.enable = true;
  # programs.gnome-keyring.secrets = true;

  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
      gtk-key-theme-name = "Emacs";
    };

    gtk4 = {
      theme = null;
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-overlay-scrolling = false;
        gtk-key-theme-name = "Emacs";
      };
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    monospace-font-name = "JetbrainsMono Nerd Font 11";
  };
}
