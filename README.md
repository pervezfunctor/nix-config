## Manual Installation

Get this config on your system with the following commands.

```bash
nix-shell -p git micro # use your favorite editor instead of micro
git clone https://github.com/pervezfunctor/nix-config.git
```

Exit nix-shell with Ctrl+D. Execute the following comands.

```bash
cd nix-config
rm -rf .git
mkdir -p hosts/$(hostname)
cp /etc/nixos/* hosts/$(hostname)/
micro flake.nix
```

Copy a section for nixos config like nuc-vm and modify it as you need it. For example minimal configuiration would be the following(You could get your hostname with `hostname` command).

```nix
"<your-host-name>" = mkOS [ ./hosts/<your-host-name>/configuration.nix ] [];
```

Now execute the following commands.

```bash
git init
git add .
sudo nixos-rebuild switch --flake .#
```

Create an empty `zsh` rc file.

```bash
touch ~/.zshrc
```

Reboot your system. Remember  to commit and push your code to a new repository(github/codeberg).

## Automated setup

To automate the above setup process, download and run the provided `setup.nu` script:

```bash
curl -O https://raw.githubusercontent.com/pervezfunctor/nix-config/refs/heads/main/bin/setup.nu
nix run nixpkgs#nushell -- ./setup.nu
rm -f ./setup.nu
```
