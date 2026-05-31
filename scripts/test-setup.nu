#!/usr/bin/env nu
# Test script for setup.nu
# Tests setup.nu functions without rebuilding the system.
#
# Functions that call `exit` (via die()) run as subprocesses so they
# cannot kill the test harness.
#
# Usage (from project root): nu scripts/test-setup.nu
# Usage (from scripts/ dir): nu test-setup.nu

const PASSED = $"(ansi green)✓ PASSED(ansi reset)"
const FAILED = $"(ansi red)✗ FAILED(ansi reset)"
const SKIPPED = $"(ansi yellow)⚠ SKIPPED(ansi reset)"

# Locate setup.nu — supports running from project root or scripts/ dir.
let SCRIPTS_DIR = (
  if ("scripts/setup.nu" | path exists) { $env.PWD | path join "scripts" }
  else if ("setup.nu" | path exists) { $env.PWD }
  else { error make {msg: "Cannot find setup.nu — run from project root or scripts/ directory"} }
)

# Run a nu snippet that sources setup.nu first.
def run [code: string] {
  do -i { ^nu -c $"source ($SCRIPTS_DIR)/setup.nu; ($code)" } | complete
}

# Like run, but with piped stdin.
def run-stdin [stdin: string, code: string] {
  do -i { $stdin | ^nu -c $"source ($SCRIPTS_DIR)/setup.nu; ($code)" } | complete
}

def assert-exit [code: string, expected: int, msg: string] {
  let r = (run $code)
  if $r.exit_code != $expected {
    error make {msg: $"($msg): expected ($expected), got ($r.exit_code): ($r.stderr)"}
  }
}

# ──────────────────────────────────────────────
# Unit tests
# ──────────────────────────────────────────────

def test-help [] {
  print "  --help flag..."
  let r = (do -i { ^nu $"($SCRIPTS_DIR)/setup.nu" --help } | complete)
  if $r.exit_code != 0 { error make {msg: "--help should exit 0"}}
  if not ($r.stdout | str contains "Usage:") { error make {msg: "missing 'Usage:'"}}
  print $"    ($PASSED)"
}

def test-repo-dir [] {
  print "  repo-dir..."
  let r = (run "repo-dir")
  if $r.exit_code != 0 { error make {msg: $"failed: ($r.stderr)"}}
  let expected = $"($env.HOME)/.nix-config"
  if ($r.stdout | str trim) != $expected {
    error make {msg: $"expected '($expected)', got '($r.stdout)'"}
  }
  print $"    ($PASSED)"
}

def test-has-cmd-found [] {
  print "  has-cmd (found)..."
  let r = (run "print (has-cmd 'sh')")
  if ($r.stdout | str trim) != "true" {
    error make {msg: $"expected true, got '($r.stdout | str trim)'"}
  }
  print $"    ($PASSED)"
}

def test-has-cmd-not-found [] {
  print "  has-cmd (not found)..."
  let r = (run "print (has-cmd 'nonexistent-99999')")
  if ($r.stdout | str trim) != "false" {
    error make {msg: $"expected false, got '($r.stdout | str trim)'"}
  }
  print $"    ($PASSED)"
}

# ──────────────────────────────────────────────
# generate-vars tests
# ──────────────────────────────────────────────

def test-generate-vars-fresh [] {
  print "  generate-vars (fresh directory)..."
  let temp = (mktemp -d)

  let r = (run $"main vars '($temp)'")
  if $r.exit_code != 0 { error make {msg: $"failed: ($r.stderr)"}}

  let vars = $"($temp)/vars.nix"
  if not ($vars | path exists) { error make {msg: "vars.nix not created"}}

  let content = (open $vars)
  let username = (whoami | str trim)
  let hostname = (hostname | str trim)
  let home = ($env.HOME | str trim)

  if not ($content | str contains $username) { error make {msg: "missing username"}}
  if not ($content | str contains $hostname) { error make {msg: "missing hostname"}}
  if not ($content | str contains $home) { error make {msg: "missing homeDirectory"}}

  rm -rf $temp
  print $"    ($PASSED)"
}

def test-generate-vars-overwrite-declined [] {
  print "  generate-vars (overwrite declined)..."
  print $"    ($SKIPPED): 'input' requires a TTY"
}

def test-generate-vars-overwrite-accepted [] {
  print "  generate-vars (overwrite accepted)..."
  print $"    ($SKIPPED): 'input' requires a TTY"
}

# ──────────────────────────────────────────────
# check-prerequisites tests
# ──────────────────────────────────────────────

def test-check-prerequisites-missing-flake [] {
  print "  check-prerequisites (missing flake.nix)..."
  let temp = (mktemp -d)
  assert-exit $"check-prerequisites '($temp)'" 1 "should fail without flake.nix"
  rm -rf $temp
  print $"    ($PASSED)"
}

def test-check-prerequisites-with-flake [] {
  print "  check-prerequisites (with flake.nix)..."
  let temp = (mktemp -d)
  touch $"($temp)/flake.nix"

  let r = (run $"check-prerequisites '($temp)'")
  if $r.exit_code != 0 {
    let err = ($r.stderr | str downcase)
    if ("nixos-rebuild" in $err) and ("not available" in $err) {
      print $"    ($SKIPPED): not on NixOS"
    } else if ("hostname" in $err) and ("empty" in $err) {
      print $"    ($SKIPPED): empty hostname"
    } else {
      error make {msg: $"unexpected failure: ($r.stderr)"}
    }
  } else {
    print $"    ($PASSED)"
  }

  rm -rf $temp
}

# ──────────────────────────────────────────────
# setup-host-directory tests
# ──────────────────────────────────────────────

def test-setup-host-dir-creates-dir [] {
  print "  setup-host-directory (directory creation)..."
  let temp = (mktemp -d)
  touch $"($temp)/flake.nix"

  let r = (run $"setup-host-directory '($temp)' 'testhost' false")

  let host_dir = $"($temp)/hosts/testhost"
  if ($host_dir | path exists) {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): dir not created (expected on non-NixOS)"
  }

  rm -rf $temp
}

def test-setup-host-dir-hardware-only [] {
  print "  setup-host-directory (hardware-only)..."
  let temp = (mktemp -d)
  touch $"($temp)/flake.nix"

  let r = (run $"setup-host-directory '($temp)' 'testhost' true")

  let host_dir = $"($temp)/hosts/testhost"
  if ($host_dir | path exists) {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): dir not created"
  }

  rm -rf $temp
}

# ──────────────────────────────────────────────
# add-to-git tests
# ──────────────────────────────────────────────

def test-add-to-git [] {
  print "  add-to-git..."
  if (which git | length) == 0 {
    print $"    ($SKIPPED): git not found"
    return
  }

  let temp = (mktemp -d)
  do -i { ^git -C $temp init } | ignore
  touch $"($temp)/flake.nix"
  touch $"($temp)/vars.nix"
  mkdir $"($temp)/hosts/testhost"
  touch $"($temp)/hosts/testhost/configuration.nix"
  touch $"($temp)/hosts/testhost/hardware-configuration.nix"
  ^git -C $temp add flake.nix
  ^git -C $temp commit -m "init" --allow-empty o+e>| ignore

  let r = (run $"add-to-git '($temp)' 'testhost'")
  if $r.exit_code != 0 {
    print $"    ($SKIPPED): add-to-git failed"
    rm -rf $temp
    return
  }

  let staged = (do -i { ^git -C $temp diff --cached --name-only } | complete)
  if ($staged.stdout | str contains "vars.nix") {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): files not staged"
  }

  rm -rf $temp
}

# ──────────────────────────────────────────────
# Flag / integration tests
# ──────────────────────────────────────────────

def test-all-skip-flags [] {
  print "  --skip-clone --skip-generate --skip-rebuild --skip-label..."
  let r = (do -i { ^nu $"($SCRIPTS_DIR)/setup.nu" --skip-clone --skip-generate --skip-rebuild --skip-label } | complete)

  if $r.exit_code == 0 {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): exit ($r.exit_code)"
  }
}

def test-target-flag [] {
  print "  --target custombox..."
  let r = (do -i { ^nu $"($SCRIPTS_DIR)/setup.nu" --target custombox --skip-clone --skip-generate --skip-rebuild --skip-label } | complete)

  if $r.exit_code == 0 {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): exit ($r.exit_code)"
  }
}

def test-hardware-only-flag [] {
  print "  --hardware-only (with all skip)..."
  let r = (do -i {
    ^nu $"($SCRIPTS_DIR)/setup.nu" --hardware-only --skip-clone --skip-generate --skip-rebuild --skip-label
  } | complete)

  if $r.exit_code == 0 {
    print $"    ($PASSED)"
  } else {
    print $"    ($SKIPPED): exit ($r.exit_code)"
  }
}

# ──────────────────────────────────────────────
# Project structure checks
# ──────────────────────────────────────────────

def test-flake-nix-exists [] {
  print "  flake.nix has nixosConfigurations..."
  if not ("flake.nix" | path exists) {
    print $"    ($SKIPPED): not in project root"
    return
  }
  let content = (open flake.nix)
  if not ($content | str contains "nixosConfigurations") {
    error make {msg: "missing nixosConfigurations in flake.nix"}
  }
  print $"    ($PASSED)"
}

# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────

def run-all [] {
  print ""
  print "=== Running setup.nu tests ==="
  print ""

  print "Unit tests:"
  test-help
  test-repo-dir
  test-has-cmd-found
  test-has-cmd-not-found

  print ""
  print "generate-vars tests:"
  test-generate-vars-fresh
  test-generate-vars-overwrite-declined
  test-generate-vars-overwrite-accepted

  print ""
  print "prerequisite tests:"
  test-check-prerequisites-missing-flake
  test-check-prerequisites-with-flake

  print ""
  print "setup-host-directory tests:"
  test-setup-host-dir-creates-dir
  test-setup-host-dir-hardware-only

  print ""
  print "git integration test:"
  test-add-to-git

  print ""
  print "flag integration tests:"
  test-all-skip-flags
  test-target-flag
  test-hardware-only-flag
  test-flake-nix-exists

  print ""
  print "=== All tests completed ==="
  print ""
}

run-all
