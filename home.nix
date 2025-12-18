{ vars, ... }:

{
  imports = [
    ./gtk.nix
  ];

  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "25.11";
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
