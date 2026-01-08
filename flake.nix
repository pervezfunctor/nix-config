{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

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
      mango,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix;

      mangoModules = import ./mango.nix { inherit inputs pkgs; };
      swayModules = import ./sway.nix { inherit inputs pkgs; };
      gnomeModules = import ./gnome.nix { inherit inputs pkgs; };
      niriModules = import ./niri.nix { inherit inputs pkgs; };
      hyprlandModules = import ./hyprland.nix { inherit inputs pkgs; };

      mkOS =
        osModules: homeImports:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs vars homeImports;
          };

          modules = [
            ./hosts/bd795/configuration.nix
            ./core.nix
            ./dev.nix
            ./apps.nix
            ./virt.nix

            home-manager.nixosModules.home-manager
            ./homeModule.nix
          ]
          ++ osModules;
        };

      wmOsModules = [
        mango.nixosModules.mango
        mangoModules.nixosModule
        swayModules.nixosModule
        niriModules.nixosModule
        hyprlandModules.nixosModule
      ];

      wmHomeModules = [
        mangoModules.homeModule
        swayModules.homeModule
        niriModules.homeModule
        hyprlandModules.homeModule
        ./home/noctalia.nix
      ];
    in
    {
      nixosConfigurations = {
        default = mkOS [ ] [ ];

        sway = mkOS [ swayModules.nixosModule ] [ swayModules.homeModule ./home/noctalia.nix ];

        mango =
          mkOS
            [
              mango.nixosModules.mango
              mangoModules.nixosModule
            ]
            [ mangoModules.homeModule ./home/dms.nix ];

        gnome = mkOS [ gnomeModules.nixosModule ] [ gnomeModules.homeModule ];

        niri = mkOS [ niriModules.nixosModule ] [ niriModules.homeModule ./home/dms.nix ];

        hyprland = mkOS [ hyprlandModules.nixosModule ] [ hyprlandModules.homeModule ./home/dms.nix ];

        wm = mkOS wmOsModules wmHomeModules;

        nohm = mkOS wmOsModules [ ];

      };

      homeConfigurations = {
        noctalia = home-manager.lib.homeConfiguration {
          inherit system;
          modules = [
            ./home/wm.nix
            ./home/noctalia.nix
          ];
          specialArgs = { inherit inputs vars; };
        };

        dms = home-manager.lib.homeConfiguration {
          inherit system;
          modules = [
            ./home/wm.nix
            ./home/dms.nix
          ];
          specialArgs = { inherit inputs vars; };
        };

        caelestia = home-manager.lib.homeConfiguration {
          inherit system;
          modules = [
            ./home/wm.nix
            ./home/caelestia.nix
          ];
          specialArgs = { inherit inputs vars; };
        };
      };
    };
}
