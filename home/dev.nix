{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = import ./dev-packages.nix { inherit pkgs; };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      shellAliases = {
        update-os = "sudo nixos-rebuild switch --flake ~/nix-config\#";
      };

      shellInit = ''
        if [[ -d "$HOME/.ilm" ]]; then
          source "$HOME/.ilm/share/shellrc"
        fi
      '';
    };

    starship = {
      enable = true;
      interactiveOnly = true;
      transientPrompt.right = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
