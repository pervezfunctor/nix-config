{ pkgs, inputs }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agents = inputs.llm-agents.packages.${system};

  # delta.dev's Delta ships a `delta` CLI that collides with the `delta` git
  # pager below, so expose it as `delta-cli`. The desktop entry launches the
  # original store path, and `delta-app` (the GUI) is unaffected.
  delta-dev =
    let
      pkg = inputs.delta.packages.${system}.delta;
    in
    pkgs.symlinkJoin {
      name = "delta-dev-${pkg.version}";
      paths = [ pkg ];
      postBuild = ''
        mv $out/bin/delta $out/bin/delta-cli
      '';
      meta = pkg.meta // {
        mainProgram = "delta-cli";
      };
    };
in
with pkgs;
[
  inputs.herdr-nix.packages.${system}.default
  delta-dev

  # From numtide/llm-agents.nix (cache.numtide.com)
  agents.claude-code # `claude`
  agents.claude-desktop
  agents.codex
  agents.chatgpt # ChatGPT + Codex desktop app
  agents.pi
  agents.antigravity-cli
  agents.t3code-desktop

  antigravity-fhs
  google-authenticator
  bat
  bitwarden-cli
  bottom
  clang-tools
  curl
  delta
  devbox
  devenv
  distrobox
  entr
  eza
  fd
  file
  fzf
  gdu
  gh
  ghostscript
  git
  htop
  imagemagick
  jq
  just
  lazydocker
  lazygit
  luarocks
  mermaid-cli
  nerd-fonts.jetbrains-mono
  nerd-fonts.monaspace
  newt
  nil
  nixd
  nixfmt
  nushell
  opencode
  openssl
  p7zip
  passt
  pkg-config
  procs
  ptyxis
  ripgrep
  shellcheck
  shfmt
  tealdeer
  tectonic
  tmux
  trash-cli
  tree
  tree-sitter
  unzip
  watchexec
  wget
  yazi
  yq
  zed-editor
  zip
  zoxide

  # cmake
  # gcc
  # ninja
  # nodejs
  # python3
  # gnumake
  # runme
  # act
  # boost
  # catch2_3
  # clang
  # gsl-lite
]
