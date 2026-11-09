# GUI dev apps, plus CLI tools whose closure pulls in GUI toolkits
# (X11/GTK/Qt/Chromium). Installed only on hosts that import core/gui.nix.
{ pkgs, inputs }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agents = inputs.llm-agents.packages.${system};

  # delta.dev's Delta ships a `delta` CLI that collides with the `delta` git
  # pager, so expose it as `delta-cli`. The desktop entry launches the
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
  delta-dev

  agents.claude-desktop
  agents.chatgpt # ChatGPT + Codex desktop app
  agents.t3code-desktop

  antigravity-fhs
  ptyxis
  zed-editor

  # CLI tools with GUI-heavy closures
  ghostscript # X11 output device
  imagemagick # X11 display support
  mermaid-cli # bundles Chromium via puppeteer  nerd-fonts.jetbrains-mono
  nerd-fonts.monaspace
]
