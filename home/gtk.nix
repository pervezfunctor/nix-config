{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dconf-editor
  ];

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = with pkgs.gnomeExtensions; [
        open-bar.extensionUuid
        paperwm.extensionUuid
        search-light.extensionUuid
        switcher.extensionUuid
        user-themes.extensionUuid
        windownavigator.extensionUuid
        just-perfection.extensionUuid
      ];
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3";
      color-scheme = "prefer-dark";
      # accent-color = "teal";
      gtk-key-theme = "Emacs";
      monospace-font-name = "JetbrainsMono Nerd Font 11";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      center-new-windows = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };

    # "org/gnome/shell/extensions/paperwm" = {
    #   cycle-height-steps = [
    #     0.38195
    #     0.5
    #     0.61804
    #   ];
    #   cycle-width-steps = [
    #     0.38195
    #     0.5
    #     0.61804
    #   ];
    #   default-focus-mode = 1;
    #   disable-scratch-in-overview = true;
    #   disable-topbar-styling = true;
    #   edge-preview-timeout = 700;
    #   edge-preview-timeout-continual = true;
    #   edge-preview-timeout-enable = true;
    #   gesture-enabled = false;
    #   gesture-horizontal-fingers = 4;
    #   gesture-workspace-fingers = 4;
    #   horizontal-margin = 8;
    #   last-used-display-server = "Wayland";
    #   only-scratch-in-overview = false;
    #   open-window-position = 0;
    #   restore-attach-modal-dialogs = "true";
    #   restore-edge-tiling = "true";

    #   restore-workspaces-only-on-primary = "true";
    #   selection-border-radius-bottom = 11;
    #   selection-border-radius-top = 11;
    #   selection-border-size = 4;
    #   show-focus-mode-icon = true;
    #   show-open-position-icon = true;
    #   show-window-position-bar = false;
    #   show-workspace-indicator = false;
    #   swipe-friction = [
    #     0.3
    #     0.3
    #   ];
    #   use-default-background = true;
    #   vertical-margin = 8;
    #   vertical-margin-bottom = 8;
    #   window-gap = 10;
    # };

    # "org/gnome/shell/extensions/paperwm/keybindings" = {
    #   # Window management
    #   new-window = [
    #     "<Super>Return"
    #     "<Super>n"
    #   ];
    #   close-window = [
    #     "<Super>BackSpace"
    #     "<Super>q"
    #   ];

    #   # Window navigation
    #   switch-left = [ "<Super>Left" ];
    #   switch-right = [ "<Super>Right" ];
    #   switch-up = [ "<Super>Up" ];
    #   switch-down = [ "<Super>Down" ];
    #   switch-left-loop = [ "<Super><Shift>Left" ];
    #   switch-right-loop = [ "<Super><Shift>Right" ];
    #   switch-up-loop = [ "<Super><Shift>Up" ];
    #   switch-down-loop = [ "<Super><Shift>Down" ];

    #   # Window movement
    #   move-left = [ "<Super><Ctrl>Left" ];
    #   move-right = [ "<Super><Ctrl>Right" ];
    #   move-up = [ "<Super><Ctrl>Up" ];
    #   move-down = [ "<Super><Ctrl>Down" ];

    #   # Workspace navigation
    #   switch-up-workspace = [ "<Super>Page_Up" ];
    #   switch-down-workspace = [ "<Super>Page_Down" ];
    #   move-up-workspace = [ "<Super><Ctrl>Page_Up" ];
    #   move-down-workspace = [ "<Super><Ctrl>Page_Down" ];

    #   # Monitor navigation
    #   switch-monitor-left = [ "<Super><Alt>Left" ];
    #   switch-monitor-right = [ "<Super><Alt>Right" ];
    #   switch-monitor-above = [ "<Super><Alt>Up" ];
    #   switch-monitor-below = [ "<Super><Alt>Down" ];
    #   move-monitor-left = [ "<Super><Shift><Ctrl>Left" ];
    #   move-monitor-right = [ "<Super><Shift><Ctrl>Right" ];
    #   move-monitor-above = [ "<Super><Shift><Ctrl>Up" ];
    #   move-monitor-below = [ "<Super><Shift><Ctrl>Down" ];

    #   # Window sizing
    #   toggle-maximize-width = [ "<Super>f" ];
    #   paper-toggle-fullscreen = [ "<Super><Shift>f" ];
    #   center-horizontally = [ "<Super>c" ];
    #   center-vertically = [ "<Super>v" ];
    #   center = [ "<Super><Ctrl>c" ];

    #   # Window resizing
    #   resize-w-inc = [ "<Super>plus" ];
    #   resize-w-dec = [ "<Super>minus" ];
    #   resize-h-inc = [ "<Super><Shift>plus" ];
    #   resize-h-dec = [ "<Super><Shift>minus" ];

    #   # Cycle sizes
    #   cycle-width = [ "<Super>r" ];
    #   cycle-width-backwards = [ "<Super><Alt>r" ];
    #   cycle-height = [ "<Super><Shift>r" ];
    #   cycle-height-backwards = [ "<Super><Alt><Shift>r" ];

    #   # Scratch windows
    #   toggle-scratch = [ "<Super><Ctrl>s" ];
    #   toggle-scratch-window = [ "<Super><Ctrl>Return" ];

    #   # Bar toggles
    #   toggle-top-and-position-bar = [ "<Super><Ctrl>b" ];
    #   toggle-top-bar = [ "<Super><Ctrl>t" ];
    #   toggle-position-bar = [ "<Super><Ctrl>p" ];

    #   # Alt-tab
    #   live-alt-tab = [
    #     "<Super>Tab"
    #     "<Alt>Tab"
    #   ];
    #   live-alt-tab-backward = [
    #     "<Super><Shift>Tab"
    #     "<Alt><Shift>Tab"
    #   ];
    #   live-alt-tab-scratch = [ "<Alt><Ctrl>Tab" ];
    #   live-alt-tab-scratch-backward = [ "<Shift><Alt><Ctrl>Tab" ];

    #   # Previous workspace
    #   previous-workspace = [ "<Super>Above_Tab" ];
    #   previous-workspace-backward = [ "<Super><Shift>Above_Tab" ];
    #   move-previous-workspace = [ "<Super><Ctrl>Above_Tab" ];
    #   move-previous-workspace-backward = [ "<Super><Shift><Ctrl>Above_Tab" ];

    #   # Misc
    #   activate-window-under-cursor = [ "<Super><Ctrl>grave" ];
    #   switch-focus-mode = [ "<Super>space" ];
    #   switch-open-window-position = [ "<Super>o" ];
    # };
  };

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
  #     };

  # qt = {
  #   enable = true;
  #   platformTheme = "qtct";
  #   style = "kvantum";
  # };

  # xdg.configFile = {
  #   "Kvantum/ArcDark".source = "${pkgs.arc-kde-theme}/share/Kvantum/ArcDark";
  #   "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=ArcDark";
  # };
}

# restore-keybinds = ''{"toggle-tiled-left":{"bind":"[\"<Super>Left\"]","schema_id":"org.gnome.mutter.keybindings"},"toggle-tiled-right":{"bind":"[\"<Super>Right\"]","schema_id":"org.gnome.mutter.keybindings"},"cancel-input-capture":{"bind":"[\"<Super><Shift>Escape\"]","schema_id":"org.gnome.mutter.keybindings"},"restore-shortcuts":{"bind":"[\"<Super>Escape\"]","schema_id":"org.gnome.mutter.wayland.keybindings"},"switch-to-workspace-last":{"bind":"[\"<Super>End\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-panels":{"bind":"[\"<Control><Alt>Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group-backward":{"bind":"[\"<Shift><Super>Above_Tab\",\"<Shift><Alt>Above_Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"unmaximize":{"bind":"[\"<Super>Down\",\"<Alt>F5\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-1":{"bind":"[\"<Super>Home\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-left":{"bind":"[\"<Super><Shift>Left\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-down":{"bind":"[\"<Super><Shift>Down\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-left":{"bind":"[\"<Super>Page_Up\",\"<Super>KP_Prior\",\"<Super><Alt>Left\",\"<Control><Alt>Left\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group":{"bind":"[\"<Super>Above_Tab\",\"<Alt>Above_Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-left":{"bind":"[\"<Super><Shift>Page_Up\",\"<Super><Shift>KP_Prior\",\"<Super><Shift><Alt>Left\",\"<Control><Shift><Alt>Left\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-right":{"bind":"[\"<Super><Shift>Page_Down\",\"<Super><Shift>KP_Next\",\"<Super><Shift><Alt>Right\",\"<Control><Shift><Alt>Right\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-panels-backward":{"bind":"[\"<Shift><Control><Alt>Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-up":{"bind":"[\"<Control><Shift><Alt>Up\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-right":{"bind":"[\"<Super>Page_Down\",\"<Super>KP_Next\",\"<Super><Alt>Right\",\"<Control><Alt>Right\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-down":{"bind":"[\"<Control><Shift><Alt>Down\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications":{"bind":"[\"<Super>Tab\",\"<Alt>Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"maximize":{"bind":"[\"<Super>Up\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-right":{"bind":"[\"<Super><Shift>Right\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications-backward":{"bind":"[\"<Shift><Super>Tab\",\"<Shift><Alt>Tab\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-up":{"bind":"[\"<Super><Shift>Up\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"shift-overview-up":{"bind":"[\"<Super><Alt>Up\"]","schema_id":"org.gnome.shell.keybindings"},"shift-overview-down":{"bind":"[\"<Super><Alt>Down\"]","schema_id":"org.gnome.shell.keybindings"},"focus-active-notification":{"bind":"[\"<Super>n\"]","schema_id":"org.gnome.shell.keybindings"},"toggle-message-tray":{"bind":"[\"<Super>v\",\"<Super>m\"]","schema_id":"org.gnome.shell.keybindings"},"rotate-video-lock-static":{"bind":"[\"<Super>o\",\"XF86RotationLockToggle\"]","schema_id":"org.gnome.settings-daemon.plugins.media-keys"}}'';
