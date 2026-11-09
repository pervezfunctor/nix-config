#!/usr/bin/env nu

# Nix Darwin/Home-Manager/NixOS deployment helper
# Usage: ndh.nu [flake_path]   (defaults to current directory)

const TARGETS = {
    nixos: "nixosConfigurations"
    darwin: "darwinConfigurations"
    home: "homeConfigurations"
}

def require [cmd: string] {
    if (which $cmd | is-empty) {
        print -e $"Missing dependency: ($cmd)"
        exit 1
    }
}

# True if the flake has this output. Avoids evaluating the configurations
# themselves (serializing a whole NixOS config to JSON always fails).
def has_attr [flake: string, attr: string] {
    (do { ^nix eval $"($flake)#($attr)" --apply "x: true" } | complete).exit_code == 0
}

# Pick one line with fzf; returns "" if cancelled.
def pick [prompt: string] {
    let result = $in | to text | do { ^fzf $"--prompt=($prompt)" } | complete
    if $result.exit_code != 0 { "" } else { $result.stdout | str trim }
}

# Run a deploy command with live output, reporting the result.
def deploy [label: string, cmd: list<string>] {
    print $"Deploying ($label) configuration..."
    try {
        run-external ...$cmd
    } catch {
        let code = $env.LAST_EXIT_CODE
        print -e $"Error: ($label) deployment failed with exit code ($code)"
        exit $code
    }
    print $"✓ ($label) deployment successful"
}

# Show this help
def "main help" [] { help main }

# Pick a NixOS/Darwin/Home Manager configuration from a flake with fzf and deploy it
def main [
    flake_path: string = "."  # Flake directory (defaults to current directory)
] {
    require nix
    require fzf

    let types = $TARGETS | columns | where {|t| has_attr $flake_path ($TARGETS | get $t) } | sort

    if ($types | is-empty) {
        print -e $"No supported flake outputs found in ($flake_path)"
        exit 1
    }

    let type = $types | pick "Config type ❯ "
    if ($type | is-empty) { exit 0 }

    let attr = $TARGETS | get $type
    let eval = do { ^nix eval --json $"($flake_path)#($attr)" --apply builtins.attrNames } | complete
    if $eval.exit_code != 0 {
        print -e $"Failed to evaluate ($attr)"
        exit 1
    }
    let names = $eval.stdout | from json

    if ($names | is-empty) {
        print -e $"No targets found for ($type)"
        exit 1
    }

    let name = $names | pick $"($type) target ❯ "
    if ($name | is-empty) { exit 0 }

    let flake_ref = $"($flake_path)#($name)"

    match $type {
        "nixos" => {
            deploy $"NixOS ($name)" [sudo nixos-rebuild switch --flake $flake_ref]
        }
        "darwin" => {
            require darwin-rebuild
            deploy $"Darwin ($name)" [darwin-rebuild switch --flake $flake_ref]
        }
        "home" => {
            require home-manager
            deploy $"Home Manager ($name)" [home-manager switch --flake $flake_ref]
        }
    }
}
