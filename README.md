# NixOS Configuration

Flake-based NixOS + home-manager configuration for several hosts and VMs.

## Layout

| Path       | Purpose                                                          |
| ---------- | ---------------------------------------------------------------- |
| `flake.nix` | Inputs, `nixosConfigurations`, `homeConfigurations`, VM packages |
| `vars.nix` | Local user/host values (`username`, `homeDirectory`, `hostname`); copy from `vars.nix.example`; keep it staged (flakes need it) but never commit it |
| `core/`    | Shared system modules: `cli.nix` (base), `gui.nix`, `virt.nix`, `vfio.nix` |
| `desktop/` | Desktop/WM modules (GNOME, niri, mango, sway, hyprland, portals) |
| `home/`    | Home-manager modules (dev tools, GUI base, shells like dms/noctalia/caelestia) |
| `hosts/`   | Per-host `configuration.nix` + `hardware-configuration.nix`     |
| `config/`  | Dotfiles for apps (kitty, foot, tmux, zed, niri, ...)           |
| `scripts/` | Setup, VM and helper scripts                                     |

## Outputs

NixOS hosts: `bd795-sv`, `bd795`, `gnome-libvirt-vm`, `niri-libvirt-vm`,
`niri-nuc-vm`, `mango-nuc-vm`, `cli-vm` (headless).

Home configs (standalone home-manager): `cli`, `noctalia`, `dms`, `caelestia`, `dmsOnly`.

Every NixOS host also has a QEMU VM package `<host>-vm`.

## Usage

```bash
cp vars.nix.example vars.nix               # then edit
sudo nixos-rebuild switch --flake .#<host> # apply a NixOS host
home-manager switch --flake .#<home>       # apply a standalone home config
nix build .#<host>-vm                      # build a test VM (or: nu scripts/vm.nu)
scripts/check-configs                      # evaluate all hosts without building
```

## Adding a host

1. `mkdir -p hosts/$(hostname) && cp /etc/nixos/* hosts/$(hostname)/`
2. Add an entry in `flake.nix`:
   ```nix
   my-host = mkOS [ ./hosts/my-host/configuration.nix ./desktop/gnome.nix ];
   ```
   Use `mkCliOS` instead of `mkOS` for a headless machine.
3. `git add . && sudo nixos-rebuild switch --flake .#my-host`

Flakes only see git-tracked files, so new files must be `git add`ed before building.

## Automated setup

```bash
curl -O https://raw.githubusercontent.com/pervezfunctor/nix-config/main/scripts/setup.nu
nu setup.nu
```
