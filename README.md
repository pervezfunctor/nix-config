## Manual Installation

Get this config on your system with the following commands(manual).

First start a nix shell with and your favourite editor
```bash
nix-shell -p git micro
```

Then clone this repository.

```bash
git clone https://github.com/pervezfunctor/nix-config.git
```

Copy your current system configuration.

```bash
cd nix-config
rm -rf .git
mkdir -p hosts/$(hostname)
cp /etc/nixos/* hosts/$(hostname)/
```
Open `flake.nix` in your favourite editor.

```bash
micro flake.nix
```

Copy a section for nixos config like nuc-vm and modify it as you need it. For example minimal configuiration would be the following(You could get your hostname with `hostname` or `hostnamectl hostname` command).

```nix
"<your-host-name>" = mkOS [ ./hosts/<your-host-name>/configuration.nix ] [];
```

Add your files to `git stash` and rebuild your nixos with the new configuration. If something fails, remember that your previous build is always available through your bootloader.

```bash
git init
git add .
sudo nixos-rebuild switch --flake .#
```

Create an empty `zsh` rc file.

```bash
touch ~/.zshrc
```

Install `vscode` extensions.

```bash
code --install-extension jnoortheen.nix-ide
code --install-extension github.github-vscode-theme
```

Use following vscode settings.

```json
{
    "workbench.colorTheme": "GitHub Dark Default",
    "editor.fontFamily": "JetbrainsMono Nerd Font",
    "editor.fontSize": 14,
    "nix.enableLanguageServer": true,
    "nix.formatterPath": "nixfmt",
    "nix.serverPath": "nixd",
    "files.trimTrailingWhitespace": true,
    "editor.tabSize": 2,
    "editor.detectIndentation": false,
    "editor.minimap.enabled": false
}
```

Reboot your system. Remember  to commit and push your code to a new repository(github/codeberg).

## Automated setup

To automate the entire setup process, download and run the provided `setup.sh` script:

```bash
curl -O https://raw.githubusercontent.com/pervezfunctor/nix-config/main/setup.sh
chmod +x setup.sh
./setup.sh
```
