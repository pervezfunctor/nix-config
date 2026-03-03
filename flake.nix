{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mango,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix;

      mangoModules = import ./desktop/mango.nix { inherit inputs pkgs; };
      niriModules = import ./desktop/niri.nix { inherit inputs pkgs; };

      baseModules = [
        ./core/core.nix
        ./core/virt.nix
        ./desktop/apps.nix
        ./desktop/portal.nix
        ./desktop/wm.nix
        home-manager.nixosModules.home-manager
        ./core/homeModule.nix
      ];

      baseImports = [ ./home/dms.nix ];

      mkOS =
        osModules: homeImports:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs vars;
            homeImports = baseImports ++ homeImports;
          };
          modules = baseModules ++ osModules;
        };

      mkHome =
        homeImports:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = baseImports ++ homeImports;
          extraSpecialArgs = { inherit inputs vars; };
        };

      allOSModules = [
        mango.nixosModules.mango
        mangoModules.nixosModule
        niriModules.nixosModule
      ];

      allHomeModules = [
        mangoModules.homeModule
        niriModules.homeModule
      ];

      mkMin = config: mkOS [ config ] [ ];
      mkNoHm = config: mkOS ([ config ] ++ allOSModules) [ ];
      mkNiri = config: mkOS [ config niriModules.nixosModule ] [ niriModules.homeModule ];
      mkAll = config: mkOS ([ config ] ++ allOSModules) allHomeModules;
      mkMango =
        config:
        mkOS
          [
            config
            mango.nixosModules.mango
            mangoModules.nixosModule
          ]
          [ mangoModules.homeModule ];
    in
    {
      nixosConfigurations = {
        nixos = mkMin ./hosts/nixos/configuration.nix;

        bd795 = mkAll ./hosts/bd795/configuration.nix;

        niri-nuc-vm =
          mkOS
            [
              niriModules.nixosModule
              ./hosts/niri-nuc-vm/configuration.nix
            ]
            [ niriModules.homeModule ];

        mango-nuc-vm =
          mkOS
            [
              mango.nixosModules.mango
              mangoModules.nixosModule
              ./hosts/mango-nuc-vm/configuration.nix
            ]
            [ mangoModules.homeModule ];

        # only for testing, you need to copy your system configuration
        # for eg: cp  /etc/nixos/* ./nixos/
        niri = mkNiri ./hosts/nixos/configuration.nix;
        mango = mkMango ./hosts/nixos/configuration.nix;
        noHm = mkNoHm ./hosts/nixos/configuration.nix;
        all = mkAll ./hosts/nixos/configuration.nix;
      };

      packages.${system} = nixpkgs.lib.mapAttrs' (n: v: {
        name = "${n}-vm";
        value = v.config.system.build.vm;
      }) self.nixosConfigurations;

      homeConfigurations = {
        dms = mkHome [ ./home/dms.nix ];

        dmsMin = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./core/home.nix
            ./home/dms.nix
            ./home/min-packages.nix
          ];
          extraSpecialArgs = { inherit inputs vars; };
        };
      };
    };
}
