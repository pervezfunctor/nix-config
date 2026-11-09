{
  description = "NixOS flake configuration";

  nixConfig = {
    extra-substituters = [
      "https://herdr.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    herdr-nix = {
      url = "github:herdrdev/herdr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Official Delta (delta.dev) flake. Upstream recommends `follows` so the
    # patched binary links against the same glibc/Mesa as the host.
    delta = {
      url = "github:zed-industries/delta-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agents. No `follows`: upstream only supports its pinned
    # nixpkgs-unstable, and their binary cache only hits with that pin.
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./vars.nix;

      # Each desktop module carries its NixOS config, its home-manager config
      # (via home-manager.sharedModules) and its default shell.
      baseOSModules = [
        ./core/core.nix
        ./core/homeModule.nix
        ./desktop/portal.nix
        ./desktop/apps.nix
        ./desktop/wm.nix
      ];

      mkOS =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs vars; };
          modules = baseOSModules ++ modules;
        };

      mkHome =
        homeImports:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ ./core/home.nix ] ++ homeImports;
          extraSpecialArgs = { inherit inputs vars; };
        };
    in
    {
      nixosConfigurations = {
        # btrfs subvols + EFI GRUB + GNOME + GPU passthrough
        bd795-sv = mkOS [
          ./hosts/bd795-sv/configuration.nix
          ./core/virt.nix
          ./core/vfio.nix # binds dGPU + audio + USB ctlr to vfio-pci
          ./desktop/gnome.nix
        ];

        bd795 = mkOS [
          ./hosts/bd795/configuration.nix
          ./core/virt.nix
          ./desktop/gnome.nix
          ./desktop/mango.nix
          ./desktop/niri.nix
        ];

        gnome-libvirt-vm = mkOS [
          ./hosts/libvirt-vm/configuration.nix
          { networking.hostName = "gnome-libvirt-vm"; }
          ./desktop/gnome.nix
        ];

        niri-libvirt-vm = mkOS [
          ./hosts/libvirt-vm/configuration.nix
          { networking.hostName = "niri-libvirt-vm"; }
          ./desktop/niri-greetd.nix
          ./desktop/niri.nix
        ];

        niri-nuc-vm = mkOS [
          ./hosts/niri-nuc-vm/configuration.nix
          ./desktop/niri.nix
        ];

        mango-nuc-vm = mkOS [
          ./hosts/mango-nuc-vm/configuration.nix
          ./desktop/mango.nix
        ];
      };

      packages.${system} = nixpkgs.lib.mapAttrs' (n: v: {
        name = "${n}-vm";
        value = v.config.system.build.vm;
      }) self.nixosConfigurations;

      homeConfigurations =
        let
          desktopHome = [
            ./home/wm.nix
            ./home/dev.nix
            ./home/gtk.nix
          ];
        in
        {
          noctalia = mkHome (desktopHome ++ [ ./home/noctalia.nix ]);
          dms = mkHome (desktopHome ++ [ ./home/dms.nix ]);
          caelestia = mkHome (desktopHome ++ [ ./home/caelestia.nix ]);
          dmsOnly = mkHome [
            ./home/dms.nix
            ./home/min-packages.nix
          ];
        };
    };
}
