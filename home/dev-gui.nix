{ pkgs, inputs, ... }:
{
  home.packages = import ../core/gui-packages.nix { inherit pkgs inputs; };
}
