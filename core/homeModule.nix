# Base home-manager setup. Feature modules (desktop/*.nix) and hosts add their
# own home config via `home-manager.sharedModules`.
{ inputs, vars, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit vars inputs; };

    users.${vars.username} = {
      imports = [
        ./home.nix
        ../home/dev.nix
      ];
    };
  };
}
