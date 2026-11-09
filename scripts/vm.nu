#!/usr/bin/env nu

# Show this help
def "main help" [] { help main }

def get-vm-targets [] {
  let system = "x86_64-linux"
  let output = do { ^nix eval $".#packages.($system)" --json --apply "pkgs: builtins.attrNames pkgs" } | complete

  if $output.exit_code == 0 {
    $output.stdout | from json | where ($it | str ends-with "-vm")
  } else {
    []
  }
}

# Build and run a flake's NixOS VM (packages.x86_64-linux.<target>-vm)
#
# If no target is given, shows an interactive picker.
# Target names are automatically appended with '-vm'.
def main [
  target?: string  # VM target, with or without the '-vm' suffix
  --clean(-c)      # Remove the VM disk (./<hostname>.qcow2) before building
] {
  let full_target = if ($target == null) {
    let vm_targets = get-vm-targets
    if ($vm_targets | length) == 0 {
      print "Error: No VM targets found in flake"
      exit 1
    }
    if ($vm_targets | length) == 1 { $vm_targets.0 } else {
      $vm_targets | input list "Select target:"
    }
  } else if ($target | str ends-with "-vm") {
    $target
  } else {
    $"($target)-vm"
  }

  # NixOS names the VM disk after the hostname, i.e. the target without "-vm".
  let qcow = $"./($full_target | str replace --regex '-vm$' '').qcow2"

  print $"Using target: ($full_target)"

  if $clean and ($qcow | path exists) {
    print $"Removing ($qcow)"
    rm -f $qcow
  }

  print $"Building target ($full_target)..."
  ^nix build $".#($full_target)"

  print $"Running target ($full_target)..."
  ^nix run $".#($full_target)"
}
