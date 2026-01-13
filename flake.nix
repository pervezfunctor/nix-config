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
          specialArgs = { inherit inputs vars homeImports; };

          modules = [
            ./core.nix
            ./dev.nix
            ./apps.nix
            ./virt.nix

            home-manager.nixosModules.home-manager
            ./homeModule.nix
          ]
          ++ osModules;
        };

      mkHome =
        homeImports:
        home-manager.lib.homeConfiguration {
          inherit system;
          modules = [
            ./home/wm.nix
            ./home/gtk.nix
          ]
          ++ homeImports;
          specialArgs = { inherit inputs vars; };
        };

      allOSModules = [
        mango.nixosModules.mango
        mangoModules.nixosModule
        swayModules.nixosModule
        niriModules.nixosModule
        hyprlandModules.nixosModule
      ];

      allHomeModules = [
        mangoModules.homeModule
        swayModules.homeModule
        niriModules.homeModule
        hyprlandModules.homeModule
        gnomeModules.homeModule
        ./home/caelestia.nix
        ./home/dms.nix
        ./home/noctalia.nix
      ];
    in
    {
      nixosConfigurations = {
        default = mkOS [ ] [ ];
        sway = mkOS [ swayModules.nixosModule ] [ swayModules.homeModule ./home/noctalia.nix ];
        gnome = mkOS [ gnomeModules.nixosModule ] [ gnomeModules.homeModule ];
        niri = mkOS [ niriModules.nixosModule ] [ niriModules.homeModule ./home/noctalia.nix ];
        hyprland = mkOS [ hyprlandModules.nixosModule ] [ hyprlandModules.homeModule ./home/caelestia.nix ];
        all = mkOS allOSModules allHomeModules;
        nohm = mkOS allOSModules [ ];
        mango =
          mkOS
            [
              mango.nixosModules.mango
              mangoModules.nixosModule
            ]
            [ mangoModules.homeModule ./home/dms.nix ];
        bd795 = mkOS (allOSModules ++ [ ./hosts/bd795/configuration.nix ]) allHomeModules;
        nuc-vm =
          mkOS
            [
              mango.nixosModules.mango
              mangoModules.nixosModule
              gnomeModules.nixosModule
              ./hosts/nuc-vm/configuration.nix
            ]
            [
              gnomeModules.homeModule
              mangoModules.homeModule
              ./home/dms.nix
            ];
      };

      homeConfigurations = {
        noctalia = mkHome [ ./home/noctalia.nix ];
        dms = mkHome [ ./home/dms.nix ];
        caelestia = mkHome [ ./home/caelestia.nix ];
      };
    };
}
