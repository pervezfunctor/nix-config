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
  print -e $"(ansi red)✗ ($msg)(ansi reset)"
}

def log-step [msg: string] {
  print $"(ansi yellow)($msg)(ansi reset)"
}

def die [msg: string] {
  error $msg
  exit 1
}

def get-hostname [] {
  (sys host).hostname | default "" | str trim
}

# Returns true only on an explicit y/Y. No TTY (input fails) counts as "no".
def confirm-prompt [prompt: string] {
  let answer = try { input $prompt | str trim } catch { "" }
  $answer in ["y" "Y"]
}

def confirm-overwrite [file: string] {
  if not (confirm-prompt $"($file) already exists. Overwrite? [y/N]: ") {
    die "Aborted."
  }
}

# Clone the nix-config repository (skipped if it already exists)
def "main dotfiles" [repo_dir: string] {
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

  let hostname = (get-hostname)
  if ($hostname | is-empty) {
    die "Hostname is empty"
  }

  log $"Prerequisites check passed \(hostname: ($hostname)\)"
}

# Generate vars.nix with the current user, home directory and hostname
def "main vars" [repo_dir: string] {
  log-step "Step 2: Generating vars.nix..."

  let username = (whoami | str trim)
  let homeDirectory = ($env.HOME | str trim)
  let hostname = (get-hostname)
  let vars_file = $"($repo_dir)/vars.nix"

  if ($username | is-empty) { die "USER is empty" }

  if ($homeDirectory | is-empty) or not ($homeDirectory | path exists) {
    die $"Invalid home directory: ($homeDirectory)"
  }

  if ($hostname | is-empty) { die "Hostname is empty" }

  if ($vars_file | path exists) {
    confirm-overwrite $vars_file
  }

  # Optional: carry over an existing global git identity, if any.
  let git_lines = (
    [[key field]; ["user.name" "gitName"] ["user.email" "gitEmail"]]
    | each { |it|
      let value = (do -i { ^git config --global --get $it.key } | complete | get stdout | str trim)
      if ($value | is-empty) { null } else { $"  ($it.field) = \"($value)\";\n" }
    }
    | compact
    | str join
  )

  let nix_content = $"
{
  username = \"($username)\";
  homeDirectory = \"($homeDirectory)\";
  hostname = \"($hostname)\";
($git_lines)}
"

  try {
    $nix_content | save -f $vars_file
  } catch { |e|
    die $"Failed to write ($vars_file).\n($e.msg)"
  }

  log $"vars.nix generated: username=($username), home=($homeDirectory), hostname=($hostname)"
}

# nixos-generate-config needs root to probe hardware (e.g. btrfs subvolumes).
def setup-host-directory [repo_dir: string, target: string, hardware_only: bool] {
  let host_dir = $"($repo_dir)/hosts/($target)"

  log-step $"Step 3: Setting up host directory for '($target)'..."

  if not (has-cmd nixos-generate-config) {
    die "nixos-generate-config is not available. Please run this script on a NixOS system."
  }

  if not ($host_dir | path exists) {
    mkdir $host_dir
    log $"Created host directory: ($host_dir)"

    for file in ["configuration.nix" "hardware-configuration.nix"] {
      let src = $"/etc/nixos/($file)"
      if ($src | path exists) {
        cp $src $"($host_dir)/"
      } else {
        warn $"($src) not found, skipping"
      }
    }
  }

  if $hardware_only or ($"($host_dir)/configuration.nix" | path exists) {
    # Only hardware-configuration.nix needs (re)generating. Capture it and
    # save as the current user so the repo doesn't get root-owned files.
    print "Generating hardware-configuration.nix..."
    let result = (do -i { ^sudo nixos-generate-config --show-hardware-config } | complete)
    if ($result.exit_code != 0) {
      die $"Failed to generate hardware configuration.\n($result.stderr)"
    }
    $result.stdout | save -f $"($host_dir)/hardware-configuration.nix"
    log "Hardware configuration generated"
  } else {
    print "Generating NixOS configuration files..."
    let result = (do -i { ^sudo nixos-generate-config --dir $host_dir } | complete)
    if ($result.exit_code != 0) {
      die $"Failed to generate NixOS configuration.\n($result.stderr)"
    }
    let user = (whoami | str trim)
    do -i { ^sudo chown -R $user $host_dir } | complete | ignore
    log "NixOS configuration files generated"
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
        ^nix run nixpkgs#git -- -C $repo_dir add $full_path
      } | complete)
      if ($result.exit_code != 0) {
        warn $"Failed to add ($file) to git: ($result.stderr | str trim)"
      } else {
        log $"Added ($file) to git"
      }
    }
  }

  print "Review changes with: git status"
}

def label-boot-partition [] {
  log-step "Step 4: Labeling boot partition..."

  let boot_dev = (do -i { ^findmnt -n -o SOURCE /boot } | complete | get stdout | str trim)
  if ($boot_dev | is-empty) {
    warn "Could not detect boot partition mount"
    return
  }

  if (confirm-prompt $"Label ($boot_dev) as BOOT for by-label disk references? [y/N]: ") {
    let result = (do -i { ^sudo fatlabel $boot_dev BOOT } | complete)
    if ($result.exit_code != 0) {
      warn $"Failed to label boot partition.\n($result.stderr)"
    } else {
      log $"Boot partition ($boot_dev) labeled as BOOT"
    }
  } else {
    warn "Skipping boot partition labeling"
  }
}

# Rebuild NixOS from the flake for the given target
def "main rebuild" [repo_dir: string, target: string] {
  log-step "Step 5: Rebuilding NixOS configuration..."

  let flake_ref = $"($repo_dir)#($target)"

  # Check only that the attribute exists; evaluating the whole system
  # configuration would take forever.
  let check = (do -i {
    ^nix eval $"($repo_dir)#nixosConfigurations.($target)" --apply "x: true"
  } | complete)
  if ($check.exit_code != 0) {
    warn $"No '($target)' entry in flake.nix nixosConfigurations"
    print "Add this to nixosConfigurations in flake.nix (mkOS for a desktop, mkCliOS for headless):"
    print $"  ($target) = mkOS [ ./hosts/($target)/configuration.nix ];"
    print $"Then run: sudo nixos-rebuild switch --flake ($flake_ref)"
    return
  }

  if (confirm-prompt $"Rebuild NixOS with '--flake ($flake_ref)'? [y/N]: ") {
    print $"Running: sudo nixos-rebuild switch --flake ($flake_ref)"
    try {
      ^sudo nixos-rebuild switch --flake $flake_ref
    } catch {
      die $"NixOS rebuild failed \(exit code ($env.LAST_EXIT_CODE)\)"
    }
    log "NixOS rebuild complete"
  } else {
    warn "Skipping rebuild"
    print $"Run manually: sudo nixos-rebuild switch --flake ($flake_ref)"
  }
}

# NixOS Config Setup Script
#
# 1. Clones nix-config repository to ~/.nix-config
# 2. Generates vars.nix with current user info
# 3. Creates host directory, copies /etc/nixos, and generates config files
# 4. Adds generated files to git
# 5. Labels boot partition (optional)
# 6. Prompts to rebuild the system
def main [
  --target: string = "nixos"  # Host target name (hosts/<target>, flake .#<target>)
  --skip-clone                # Skip cloning the repository
  --skip-generate             # Skip generating NixOS config files
  --skip-rebuild              # Skip rebuild prompt
  --skip-label                # Skip boot partition labeling
  --hardware-only             # Only generate hardware-configuration.nix
] {
  print $"(ansi green)=== NixOS Config Setup ===(ansi reset)\n"

  let repo_dir = (repo-dir)

  if not $skip_clone {
    main dotfiles $repo_dir
  }

  if not ($repo_dir | path exists) {
    die $"Repository directory does not exist: ($repo_dir)"
  }

  cd $repo_dir

  check-prerequisites $repo_dir
  main vars $repo_dir

  if not $skip_generate {
    setup-host-directory $repo_dir $target $hardware_only
  }

  add-to-git $repo_dir $target

  if not $skip_label {
    label-boot-partition
  }

  if not $skip_rebuild {
    main rebuild $repo_dir $target
  }

  print ""
  print $"(ansi green)=== Setup Complete ===(ansi reset)"
  print "Your NixOS configuration is now ready!"
  print "Remember to reboot your system and commit your changes."
}
