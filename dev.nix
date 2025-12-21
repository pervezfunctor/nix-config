{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    act
    antigravity
    bat
    bitwarden-cli
    curl
    delta
    devbox
    devenv
    distrobox
    eza
    file
    fd
    fzf
    gcc
    gh
    gnumake
    git
    delta
    htop
    jq
    just
    neovim
    nerd-fonts.jetbrains-mono
    newt
    nixd
    nixfmt-rfc-style
    openssl
    passt
    p7zip
    procs
    ptyxis
    ripgrep
    runme
    shellcheck
    shfmt
    stow
    tealdeer
    tmux
    trash-cli
    tree
    unzip
    vscode
    wget
    yq
    zoxide
  ];

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
