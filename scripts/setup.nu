#!/usr/bin/env nu

const REPO_URL = "https://github.com/pervezfunctor/nix-config.git"

def repo-dir [] {
  $"($env.HOME)/.nix-config"
}

def has-cmd [cmd: string] {
  (which $cmd | length) > 0
}

def log [msg: string] {
  print $"(ansi green)✓ ($msg)(ansi reset)"
}

def warn [msg: string] {
  print $"(ansi yellow)⚠ ($msg)(ansi reset)"
}

def error [msg: string] {
  print $"(ansi red)✗ ($msg)(ansi reset)"
}

def log-step [msg: string] {
  print $"(ansi yellow)($msg)(ansi reset)"
}

def die [msg: string] {
  error $msg
  exit 1
}

def confirm-prompt [prompt: string] {
  let answer = (input $prompt | str trim | str downcase)
  $answer == "y"
}

def confirm-overwrite [file: string] {
  if not (confirm-prompt $"($file) already exists. Overwrite? [y/N]: ") {
    error make {msg: "Aborted."}
  }
}

def clone-or-update-repo [repo_dir: string] {
  log-step "Step 1: Cloning nix-config repository..."

  if ($repo_dir | path exists) and ($"($repo_dir)/.git" | path exists) {
    warn "Repository already exists, skipping clone"
    print $"Working directory: ($repo_dir)"
    return
  }

  if not (has-cmd nix) {
    die "nix is not installed. Please install Nix first."
  }

  let result = (do -i {
    ^nix run nixpkgs#git -- clone --depth 1 $REPO_URL $repo_dir
  } | complete)

  if ($result.exit_code != 0) {
    die $"Failed to clone repository.\n($result.stderr)"
  }

  if not ($repo_dir | path exists) {
    die $"Clone succeeded but directory not found: ($repo_dir)"
  }

  log "Repository cloned successfully"
  print $"Working directory: ($repo_dir)"
}

def check-prerequisites [repo_dir: string] {
  log-step "Checking prerequisites..."

  if not ($"($repo_dir)/flake.nix" | path exists) {
    die "flake.nix not found. Please run this script from the nix-config root directory."
  }

  if not (has-cmd nixos-rebuild) {
    die "nixos-rebuild is not available. Please run this script on a NixOS system."
  }

  let hostname = (hostname | str trim)
  if ($hostname | is-empty) {
    die "Hostname is empty"
  }

  log ("Prerequisites check passed (hostname: " + $hostname + ")")
}

def generate-vars [repo_dir: string] {
  log-step "Step 2: Generating vars.nix..."

  let username = (whoami | str trim)
  let homeDirectory = ($env.HOME | str trim)
  let hostname = (hostname | str trim)
  let vars_file = $"($repo_dir)/vars.nix"

  if ($username | is-empty) { die "USER is empty" }

  if ($homeDirectory | is-empty) or not ($homeDirectory | path exists) {
    die $"Invalid home directory: ($homeDirectory)"
  }

  if ($hostname | is-empty) { die "Hostname is empty" }

  if ($vars_file | path exists) {
    confirm-overwrite $vars_file
  }

  let nix_content = $"
{
  username = \"($username)\";
  homeDirectory = \"($homeDirectory)\";
  hostname = \"($hostname)\";
}
"

  try {
    $nix_content | save -f $vars_file
  } catch { |e|
    die $"Failed to write ($vars_file).\n($e)"
  }

  log $"vars.nix generated: username=($username), home=($homeDirectory), hostname=($hostname)"
}

def setup-host-directory [repo_dir: string, target: string, hardware_only: bool] {
  let host_dir = $"($repo_dir)/hosts/($target)"

  log-step $"Step 3: Setting up host directory for '($target)'..."

  if not ($host_dir | path exists) {
    mkdir $host_dir
    log $"Created host directory: ($host_dir)"

    if ("/etc/nixos" | path exists) {
      cp "/etc/nixos/configuration.nix" $"($host_dir)/"
      cp "/etc/nixos/hardware-configuration.nix" $"($host_dir)/"
      log "Copied NixOS configuration from /etc/nixos"
    }
  }

  if $hardware_only {
    print "Generating hardware-configuration.nix..."
    let hw_file = $"($host_dir)/hardware-configuration.nix"
    let result = (do -i {
      nixos-generate-config --dir $host_dir --show-hardware-config | save -f $hw_file
    } | complete)
    if ($result.exit_code != 0) {
      die $"Failed to generate hardware configuration.\n($result.stderr)"
    }
    log "Hardware configuration generated"
  } else {
    print "Regenerating NixOS configuration files..."
    let result = (do -i { nixos-generate-config --dir $host_dir } | complete)
    if ($result.exit_code != 0) {
      die $"Failed to generate NixOS configuration.\n($result.stderr)"
    }
    log "NixOS configuration files regenerated"
  }
}

def add-to-git [repo_dir: string, target: string] {
  print ""
  print "Adding generated files to git..."

  let is_repo = (do -i {
    ^nix run nixpkgs#git -- -C $repo_dir rev-parse --git-dir
  } | complete | get exit_code) == 0

  if not $is_repo {
    print "Not in a git repository. Skipping git operations."
    return
  }

  let host_dir = $"hosts/($target)"
  let files_to_add = [
    "vars.nix"
    $"($host_dir)/hardware-configuration.nix"
    $"($host_dir)/configuration.nix"
  ]

  for file in $files_to_add {
    let full_path = $"($repo_dir)/($file)"
    if ($full_path | path exists) {
      let result = (do -i {
        ^nix run nixpkgs#git -- -C $repo_dir add $full_path 2>/dev/null
      } | complete)
      if ($result.exit_code != 0) {
        warn $"Failed to add ($file) to git"
      } else {
        log $"Added ($file) to git"
      }
    }
  }

  print "Review changes with: git status"
}

def label-boot-partition [] {
  log-step "Step 4: Labeling boot partition..."

  if (confirm-prompt "Label /dev/vda1 as BOOT for by-label disk references? [y/N]: ") {
    let result = (do -i { sudo fatlabel /dev/vda1 BOOT } | complete)
    if ($result.exit_code != 0) {
      warn $"Failed to label boot partition.\n($result.stderr)"
    } else {
      log "Boot partition labeled as BOOT"
    }
  } else {
    warn "Skipping boot partition labeling"
  }
}

def prompt-rebuild [repo_dir: string, target: string] {
  log-step "Step 5: Rebuilding NixOS configuration..."

  cd $repo_dir
  let check = (do -i { ^nix eval $".#nixosConfigurations.($target)" } | complete)
  if ($check.exit_code != 0) {
    warn $"No '($target)' entry in flake.nix nixosConfigurations"
    print $"Add this to flake.nix:"
    print $"  ($target) = mkMin ./hosts/($target)/configuration.nix;"
    print $"Then run: sudo nixos-rebuild switch --flake .#($target)"
    return
  }

  if (confirm-prompt $"Rebuild NixOS with '--flake .#($target)'? [y/N]: ") {
    print $"Running: sudo nixos-rebuild switch --flake ($repo_dir)/#($target)"
    let result = (do -i { sudo nixos-rebuild switch --flake $"($repo_dir)/#($target)" } | complete)
    if ($result.exit_code != 0) {
      die $"NixOS rebuild failed.\n($result.stderr)"
    }
    log "NixOS rebuild complete"
  } else {
    warn "Skipping rebuild"
    print $"Run manually: sudo nixos-rebuild switch --flake ($repo_dir)/#($target)"
  }
}

def print-help [] {
  print ""
  print "NixOS Config Setup Script"
  print ""
  print "Usage:"
  print "  nu setup.nu [--target <name>] [--skip-clone] [--skip-generate] [--skip-rebuild] [--skip-label] [--hardware-only]"
  print ""
  print "Description:"
  print "  1. Clones nix-config repository to ~/.nix-config"
  print "  2. Generates vars.nix with current user info"
  print "  3. Creates host directory, copies /etc/nixos, and generates config files"
  print "  4. Labels boot partition (optional)"
  print "  5. Adds generated files to git"
  print "  6. Prompts to rebuild the system"
  print ""
  print "Options:"
  print "  --target <name>   Host target (default: nixos)"
  print "  --skip-clone      Skip cloning/pulling repository"
  print "  --skip-generate   Skip generating NixOS config files"
  print "  --skip-rebuild    Skip rebuild prompt"
  print "  --skip-label      Skip boot partition labeling"
  print "  --hardware-only   Only generate hardware-configuration.nix"
  print "  -h, --help        Show this help message"
  print ""
}

# NixOS Config Setup Script
#
# 1. Clones nix-config repository to ~/.nix-config
# 2. Generates vars.nix with current user info
# 3. Creates host directory, copies /etc/nixos, and generates config files
# 4. Labels boot partition (optional)
# 5. Adds generated files to git
# 6. Prompts to rebuild the system
def main [
  --target: string = "nixos"
  --skip-clone
  --skip-generate
  --skip-rebuild
  --skip-label
  --hardware-only
] {
  print $"(ansi green)=== NixOS Config Setup ===(ansi reset)\n"

  let repo_dir = (repo-dir)

  if not $skip_clone {
    clone-or-update-repo $repo_dir
  }

  if not ($repo_dir | path exists) {
    die $"Repository directory does not exist: ($repo_dir)"
  }

  cd $repo_dir

  check-prerequisites $repo_dir
  generate-vars $repo_dir

  if not $skip_generate {
    setup-host-directory $repo_dir $target $hardware_only
  }

  add-to-git $repo_dir $target

  if not $skip_label {
    label-boot-partition
  }

  if not $skip_rebuild {
    prompt-rebuild $repo_dir $target
  }

  print ""
  print $"(ansi green)=== Setup Complete ===(ansi reset)"
  print "Your NixOS configuration is now ready!"
  print "Remember to reboot your system and commit your changes."
}
