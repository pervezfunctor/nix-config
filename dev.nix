{ pkgs, ... }:

let
  shellInit = ''
    if [[ -d "$HOME/.ilm" ]]; then
      source "$HOME/.ilm/share/shellrc"
    fi
  '';
  shellAliases = {
    nrs = "update-os";
  };
in

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = import ./dev-packages.nix { inherit pkgs; };

  services.openssh.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than-1d";
      persistent = true;
    };
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      inherit shellAliases shellInit;
    };

    bash = {
      enable = true;
      inherit shellAliases shellInit;
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
