{ pkgs, ... }:
{
  home.packages = import ../core/dev-packages.nix { inherit pkgs; };

  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        update-os = "sudo nixos-rebuild switch --flake ~/nix-config\#";
      };
    };

    nushell = {
      enable = true;
      plugins = [ pkgs.nushellPlugins.formats ];
      settings = {
        show_banner = false;
      };
    };

    broot = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    mise = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    lazygit = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    # keychain = {
    #   enable = true;
    #   keys = [ "id_ed25519" ];
    #   enableBashIntegration = true;
    #   enableNushellIntegration = true;
    #   enableZshIntegration = true;
    # };
  };
}
