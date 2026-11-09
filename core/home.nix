{ vars, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "26.05";

  programs = {
    home-manager.enable = true;
  };
}
