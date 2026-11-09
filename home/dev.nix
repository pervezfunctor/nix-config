{
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:
{
  home.packages = import ../core/cli-packages.nix { inherit pkgs inputs; };

  programs = {
    git = {
      enable = true;
      settings = {
        # gitName/gitEmail are optional in vars.nix; unset ones are omitted.
        user = lib.mkIf (vars ? gitName || vars ? gitEmail) (
          lib.optionalAttrs (vars ? gitName) { name = vars.gitName; }
          // lib.optionalAttrs (vars ? gitEmail) { email = vars.gitEmail; }
        );
        safe.directory = "${vars.homeDirectory}/.nix-config";
        init.defaultBranch = "main";
        diff = {
          colorMoved = "default";
          tool = "difftastic";
        };
        difftool = {
          prompt = false;
          # Wired by hand: home-manager won't enable delta's and difftastic's
          # git integrations together.
          difftastic.cmd = "${lib.getExe pkgs.difftastic} --display=side-by-side --background=dark --color=always $LOCAL $REMOTE";
        };
      };
    };

    # Pager for `git diff`/`show`/`log -p`/`add -p` (and lazygit).
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };

    # Structural diffs on demand via `git difftool`.
    difftastic.enable = true;

    # Registers `gh auth git-credential` as the credential helper for
    # github.com / gist.github.com. Home-manager regenerates the store path on
    # every switch, so it never goes stale after GC.
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "https";
        prompt = "enabled";
        aliases.co = "pr checkout";
      };
    };

    zsh = {
      enable = true;
    };

    nushell = {
      enable = true;
      plugins = [ pkgs.nushellPlugins.formats ];
      loadSessionVariables = false;
      settings = {
        show_banner = false;
      };
      # shellAliases = { };
      # environmentVariables = { };
      # configFile.source = ./config/nu/config.nu;
      # envFile.source = ./config/nu/env.nu;
      # extraConfig = '' '';
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
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
      enableFishIntegration = true;
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
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    lazygit = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
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
    #   enableZshIntegration = true;
    #   enableBashIntegration = true;
    #   enableNushellIntegration = true;
    # };

    # atuin = {
    #   enable = true;
    #   enableZshIntegration = true;
    #   enableBashIntegration = true;
    #   enableNushellIntegration = true;
    # };

    # yazi = {
    #   enable = true;
    #   enableZshIntegration = true;
    #   enableBashIntegration = true;
    #   enableNushellIntegration = true;
    # };
  };
}
