{ pkgs, ... }:
{
  environment.systemPackages = import ./wm-packages.nix { inherit pkgs; };
}
