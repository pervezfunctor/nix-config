# Repository conventions

## Privilege escalation: `pkexec` for agents, `sudo` for user instructions

### Agents and automated tooling → use `pkexec`

Any command an agent (ZCode subagent, automated workflow) runs that needs root
**must** use `pkexec`, never `sudo`.

```sh
pkexec btrfs subvolume list /
pkexec mount -o ro,subvol=@cachyos /dev/nvme1n1p3 /mnt/probe
```

When using pkexec, use the SHELL environment variable to set it correctly.

### User-facing instructions → use `sudo`

When writing instructions or commands for the **user** to run themselves in
their own terminal, use `sudo`. The user has normal terminal sudo access
(passwordless for `nixos-rebuild` specifically, see `configuration.nix`).

```sh
sudo nixos-rebuild switch --flake .#bd795-sv
sudo chattr +C /var/lib/libvirt/images
```

## vars.nix

Never commit `vars.nix` file. When it's staged, unstage it, create commits, and then stage it again.
