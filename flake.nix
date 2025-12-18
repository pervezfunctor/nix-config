{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./vars.nix;

      mkOS =
        osModules: homeImports:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit vars;
          };

          modules = [
            ./configuration.nix
            ./virt.nix

            {
              programs.niri.enable = true;
            }

            inputs.mango.nixosModules.mango
            {
              programs.mango.enable = true;
            }

            # catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = {
                  inherit vars;
                };
                users.${vars.username} = {
                  imports = [
                    ./home.nix
                    # catppuccin.homeModules.catppuccin
                    # inputs.noctalia.homeModules.default
                    # inputs.caelestia.homeManagerModules.default
                    inputs.dms.homeModules.dankMaterialShell.default
                    inputs.mango.hmModules.mango
                  ]
                  ++ homeImports;
                };
              };
            }
          ]
          ++ osModules;
        };

    in
    {
      nixosConfigurations = {
        nixos = mkOS [ ] [ ];

        niri = mkOS [ ./niri.nix ] [ ./home/noctalia.nix ];

        hyprland = mkOS [ ./hyprland.nix ] [ ./home/dms.nix ];

        all = mkOS [ ./hyprland.nix ./niri.nix ] [ ./home/hyprland.nix ./home/dms.nix ./home/mango.nix ];
      };
    };
}
