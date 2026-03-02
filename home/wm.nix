{ pkgs, ... }:
{
  home.packages = import ./wm-packages.nix { inherit pkgs; };
}
