{ vars, pkgs, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "25.11";

  home.pointerCursor = {
    # gtk.enable = true;
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

    kitty = {
      enable = true;
      settings = {
        font_family = "JetBrainsMono Nerd Font";
        font_size = 12;
        background_opacity = "0.96";
        include = "$HOME/.config/kitty/themes/noctalia.conf";
      };
    };
  };
}

#   gtk = {
#     enable = true;

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
#   };
# }
