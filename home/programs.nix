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
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    mise = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    lazygit = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    keychain = {
      enable = true;
      keys = [ "id_ed25519" ];
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
