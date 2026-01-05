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
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix;
      mango = import ./mango.nix { inherit inputs pkgs; };

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

    in
    {
      nixosConfigurations = {
        sway =
          let
            sway = import ./sway.nix { inherit inputs pkgs; };
          in
          mkOS [ sway.nixosModule ] [ sway.homeModule ./home/noctalia.nix ];

        mango =
          mkOS
            [
              inputs.mango.nixosModules.mango
              mango.nixosModule
            ]
            [ mango.homeModule ./home/dms.nix ];

        mangosway =
          let
            sway = import ./sway.nix { inherit inputs pkgs; };
          in
          mkOS
            [
              inputs.mango.nixosModules.mango
              mango.nixosModule
              sway.nixosModule
            ]
            [
              mango.homeModule
              sway.homeModule
              ./home/dms.nix
              ./home/noctalia.nix
            ];

        gnome =
          let
            gnome = import ./gnome.nix { inherit inputs pkgs; };
          in
          mkOS [ gnome.nixosModule ] [ gnome.homeModule ];

        niri =
          let
            niri = import ./niri.nix { inherit inputs pkgs; };
          in
          mkOS [ niri.nixosModule ] [ niri.homeModule ./home/dms.nix ];

        hyprland =
          let
            hyprland = import ./hyprland.nix { inherit inputs pkgs; };
          in
          mkOS [ hyprland.nixosModule ] [ hyprland.homeModule ./home/hyprpanel.nix ];
      };
    };

  # homeConfigurations = {
  #   noctalia = home-manager.lib.homeConfiguration {
  #     inherit system;
  #     modules = [
  #       ./home/noctalia.nix
  #       ./home/common.nix
  #     ];
  #     specialArgs = { inherit inputs vars; };
  #   };

  #   dms = home-manager.lib.homeConfiguration {
  #     inherit system;
  #     modules = [
  #       ./home/dms.nix
  #       ./home/common.nix
  #     ];
  #     specialArgs = { inherit inputs vars; };
  #   };
  # };
}
