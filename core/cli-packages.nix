# Terminal-only dev tools: safe for headless hosts. Anything that is a GUI app
# or drags a GUI toolkit into the closure belongs in gui-packages.nix.
{ pkgs, inputs }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agents = inputs.llm-agents.packages.${system};
in
with pkgs;
[
  inputs.herdr-nix.packages.${system}.default

  # From numtide/llm-agents.nix (cache.numtide.com)
  agents.claude-code # `claude`
  agents.codex
  agents.pi
  agents.antigravity-cli

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
  git
  htop
  jq
  just
  lazydocker
  lazygit
  luarocks
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
  yq
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
