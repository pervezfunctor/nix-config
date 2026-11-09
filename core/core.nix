{ pkgs, vars, ... }:
let
  shellInit = ''
    if [[ -d "$HOME/.ilm" ]]; then
      source "$HOME/.ilm/share/shellrc"
    fi
  '';

  shellAliases = {
    update-os = "sudo nixos-rebuild switch --flake ~/.nix-config\#";
    nrs = "update-os";
    zed = "zeditor";

    gs = "git stash";
    gp = "git push";
    gb = "git branch";
    gbc = "git checkout -b";
    gsl = "git stash list";
    gst = "git status";
    gsu = "git status -u";
    gcan = "git commit --amend --no-edit";
    gsa = "git stash apply";
    gfm = "git pull";
    gcm = "git commit -m";
    gia = "git add";
    gco = "git checkout";
    gh-refresh = "gh auth refresh -h github.com";

    f = "fd";
    g = "git";
    h = "btm";
    p = "pixi global install";
    t = "tmux";
    v = "nvim";

    fpi = "flatpak install --user flathub";
    fpr = "flatpak remove --user";
    fps = "flatpak search";
    fpu = "flatpak update --user";

    l = "eza --icons --group-directories-first";
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -a --icons --group-directories-first";
    lla = "eza -la --icons --group-directories-first";
    lt = "eza --tree --icons --group-directories-first";
  };
in
{
  hardware.graphics = {
    enable = true;
  };
  # environment.variables = {
  #   VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";
  # };

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Add ~/.local/bin to PATH for all users and shells
  environment.localBinInPath = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
    # Don't set TERM here: it would override every login session (tty, ssh,
    # root) via pam_env. Terminal emulators set TERM themselves.
    TERMINAL = "kitty";
  };

  services.power-profiles-daemon.enable = true; # or services.tuned.enable for laptop
  services.upower.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # thumbnailer for nautilus/thunar
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;

      # Without this the daemon drops the `extra-substituters` /
      # `extra-trusted-public-keys` that flake.nix's `nixConfig` hands it:
      #   "ignoring untrusted substituter ..."
      #   "ignoring the client-specified setting 'trusted-public-keys'"
      trusted-users = [ vars.username ]; # merged with the "root" default

      # Declare the caches system-wide as well, so they are used even when
      # the flake's nixConfig is not in play (e.g. root/daemon-only builds).
      extra-substituters = [
        "https://herdr.cachix.org"
        "https://cache.numtide.com"
      ];
      extra-trusted-public-keys = [
        "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      # Keep enough generations to roll back a bad kernel/bootloader/VFIO change.
      options = "--delete-older-than 14d";
      persistent = true;
    };
  };

  # Key-only SSH on every host that enables openssh.
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.defaultUserShell = pkgs.fish;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    inherit shellInit shellAliases;
  };

  programs.fish = {
    enable = true;
    inherit shellAliases;
  };

  programs.bash = {
    enable = true;
    completion.enable = true;
    inherit shellInit shellAliases;
  };

  programs.starship = {
    enable = true;
    interactiveOnly = true;
    transientPrompt.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      fira-code
      font-awesome
      inter
      inter-nerdfont
      nerd-fonts.jetbrains-mono
      nerd-fonts.monaspace
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      # defaultFonts = {
      #   serif = [ "Noto Serif" ];
      #   sansSerif = [
      #     "Inter"
      #     "Noto Sans"
      #   ];
      # };
    };
  };

  users.extraGroups.video.members = [ vars.username ];
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    udisks2
    udiskie
    wl-clipboard
    libxcb
    libxcb-wm
    adwaita-fonts
    adwaita-icon-theme
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    virglrenderer
    mesa
    mesa-demos
  ];
}
