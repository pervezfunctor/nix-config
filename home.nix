{ vars, pkgs, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "25.11";

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 32;
  };

  programs = {
    home-manager.enable = true;

    bat.enable = true;
    carapace.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;

    ghostty = {
      enable = true;
      # settings = {
      #   font-family = "JetBrainsMono Nerd Font";
      #   font-size = 12;
      # };
    };
  };
}
