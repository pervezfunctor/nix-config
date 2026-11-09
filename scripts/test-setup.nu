#!/usr/bin/env nu
# Test script for setup.nu
# Tests setup.nu without touching the real system or ~/.nix-config:
#   - every test works in its own temp directory
#   - `sudo` and `nixos-generate-config` are replaced by stubs on PATH
#   - integration runs use a fake $HOME
#   - stdin is never a TTY, so every confirm prompt answers "no"
#
# Commands that call `exit` (via die) run in a subprocess so they can't kill
# the test harness.
#
# Usage: nu scripts/test-setup.nu   (from any directory)

const SETUP = path self ./setup.nu
const REPO = path self ..

# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

def skip [reason: string] { $"skip: ($reason)" }

def fail [msg: string] { error make {msg: $msg} }

# Temp dir with stub `sudo` (runs the command as-is) and
# `nixos-generate-config` (writes predictable files, no root needed).
def make-sandbox [] {
  let root = (mktemp -d)
  let bin = $"($root)/bin"
  mkdir $bin

  "#!/bin/sh\nexec \"$@\"\n" | save $"($bin)/sudo"

  '#!/bin/sh
if [ "$1" = "--show-hardware-config" ]; then
  echo "# stub hardware config"
  exit 0
fi
if [ "$1" = "--dir" ]; then
  [ -e "$2/configuration.nix" ] || echo "# stub configuration" > "$2/configuration.nix"
  echo "# stub hardware config" > "$2/hardware-configuration.nix"
  exit 0
fi
exit 1
' | save $"($bin)/nixos-generate-config"

  ^chmod +x $"($bin)/sudo" $"($bin)/nixos-generate-config"
  {root: $root, bin: $bin}
}

def sandbox-env [sb: record] {
  {PATH: ($env.PATH | prepend $sb.bin)}
}

# Run a nu snippet with setup.nu sourced, stdin not a TTY.
def run-setup [code: string, --with: record = {}] {
  with-env $with {
    "" | do -i { ^nu -c $"source '($SETUP)'; ($code)" } | complete
  }
}

# Run setup.nu itself with arguments, stdin not a TTY.
def run-script [args: list<string>, --with: record = {}] {
  with-env $with {
    "" | do -i { ^nu $SETUP ...$args } | complete
  }
}

def git-init [dir: string] {
  ^git -C $dir init -q
  ^git -C $dir -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m init
}

# ──────────────────────────────────────────────
# Unit tests
# ──────────────────────────────────────────────

def test-help [] {
  let r = (run-script ["--help"])
  if $r.exit_code != 0 { fail "--help should exit 0" }
  if not ($r.stdout | str contains "Usage:") { fail "missing 'Usage:'" }
  if not ($r.stdout | str contains "--skip-rebuild") { fail "missing flag docs" }
}

def test-repo-dir [] {
  let r = (run-setup "repo-dir")
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  let expected = $"($env.HOME)/.nix-config"
  if ($r.stdout | str trim) != $expected {
    fail $"expected '($expected)', got '($r.stdout | str trim)'"
  }
}

def test-has-cmd [] {
  let r = (run-setup "print (has-cmd 'sh') (has-cmd 'nonexistent-99999')")
  if ($r.stdout | lines) != ["true" "false"] {
    fail $"expected [true false], got ($r.stdout | lines | to nuon)"
  }
}

def test-get-hostname [] {
  let r = (run-setup "get-hostname")
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if ($r.stdout | str trim | is-empty) { fail "hostname is empty" }
}

def test-confirm-no-tty [] {
  let r = (run-setup "print (confirm-prompt 'q? ')")
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if ($r.stdout | str trim) != "false" { fail "without a TTY, confirm should be false" }
}

# ──────────────────────────────────────────────
# main vars
# ──────────────────────────────────────────────

def test-vars-fresh [] {
  let temp = (mktemp -d)
  let r = (run-setup $"main vars '($temp)'")
  if $r.exit_code != 0 { rm -rf $temp; fail $"failed: ($r.stderr)" }

  let vars = $"($temp)/vars.nix"
  if not ($vars | path exists) { rm -rf $temp; fail "vars.nix not created" }

  let content = (open --raw $vars)
  rm -rf $temp
  for expected in [
    $"username = \"(whoami | str trim)\";"
    $"homeDirectory = \"($env.HOME)\";"
    $"hostname = \"((sys host).hostname)\";"
  ] {
    if not ($content | str contains $expected) { fail $"missing: ($expected)" }
  }
}

def test-vars-overwrite-declined [] {
  let temp = (mktemp -d)
  "sentinel" | save $"($temp)/vars.nix"
  let r = (run-setup $"main vars '($temp)'")
  let content = (open --raw $"($temp)/vars.nix")
  rm -rf $temp
  if $r.exit_code != 1 { fail $"expected exit 1, got ($r.exit_code)" }
  if $content != "sentinel" { fail "vars.nix was overwritten" }
  if not ($r.stderr | str contains "Aborted") { fail "missing 'Aborted' message" }
}

def test-vars-overwrite-accepted [] {
  skip "needs a TTY to answer 'y'"
}

# ──────────────────────────────────────────────
# check-prerequisites
# ──────────────────────────────────────────────

def test-prereq-missing-flake [] {
  let temp = (mktemp -d)
  let r = (run-setup $"check-prerequisites '($temp)'")
  rm -rf $temp
  if $r.exit_code != 1 { fail $"expected exit 1, got ($r.exit_code)" }
  if not ($r.stderr | str contains "flake.nix not found") { fail $"wrong error: ($r.stderr)" }
}

def test-prereq-with-flake [] {
  if (which nixos-rebuild | is-empty) { return (skip "not on NixOS") }
  let temp = (mktemp -d)
  touch $"($temp)/flake.nix"
  let r = (run-setup $"check-prerequisites '($temp)'")
  rm -rf $temp
  if $r.exit_code != 0 { fail $"unexpected failure: ($r.stderr)" }
}

# ──────────────────────────────────────────────
# setup-host-directory (stubbed sudo / nixos-generate-config)
# ──────────────────────────────────────────────

def test-host-dir-fresh [] {
  let sb = (make-sandbox)
  let r = (run-setup $"setup-host-directory '($sb.root)' 'testhost' false" --with (sandbox-env $sb))
  let dir = $"($sb.root)/hosts/testhost"
  let files = (ls $dir | get name | path basename | sort)
  rm -rf $sb.root
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if $files != ["configuration.nix" "hardware-configuration.nix"] {
    fail $"unexpected files: ($files | to nuon)"
  }
}

def test-host-dir-hardware-only [] {
  let sb = (make-sandbox)
  let r = (run-setup $"setup-host-directory '($sb.root)' 'testhost' true" --with (sandbox-env $sb))
  let hw = $"($sb.root)/hosts/testhost/hardware-configuration.nix"
  let content = if ($hw | path exists) { open --raw $hw } else { "" }
  rm -rf $sb.root
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if not ($content | str contains "stub hardware config") { fail "hardware config not written" }
}

def test-host-dir-keeps-configuration [] {
  let sb = (make-sandbox)
  let dir = $"($sb.root)/hosts/testhost"
  mkdir $dir
  "# my config" | save $"($dir)/configuration.nix"
  let r = (run-setup $"setup-host-directory '($sb.root)' 'testhost' false" --with (sandbox-env $sb))
  let content = (open --raw $"($dir)/configuration.nix")
  let hw_exists = ($"($dir)/hardware-configuration.nix" | path exists)
  rm -rf $sb.root
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if $content != "# my config" { fail "existing configuration.nix was overwritten" }
  if not $hw_exists { fail "hardware-configuration.nix not generated" }
}

# ──────────────────────────────────────────────
# add-to-git
# ──────────────────────────────────────────────

def test-add-to-git [] {
  if (which git | is-empty) { return (skip "git not found") }
  let temp = (mktemp -d)
  git-init $temp
  touch $"($temp)/vars.nix"
  mkdir $"($temp)/hosts/testhost"
  touch $"($temp)/hosts/testhost/configuration.nix"
  touch $"($temp)/hosts/testhost/hardware-configuration.nix"

  let r = (run-setup $"add-to-git '($temp)' 'testhost'")
  let staged = (^git -C $temp diff --cached --name-only | lines | sort)
  rm -rf $temp
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  let expected = ["hosts/testhost/configuration.nix" "hosts/testhost/hardware-configuration.nix" "vars.nix"]
  if $staged != $expected { fail $"staged ($staged | to nuon), expected ($expected | to nuon)" }
}

# ──────────────────────────────────────────────
# main rebuild (missing target only; never rebuilds)
# ──────────────────────────────────────────────

def test-rebuild-missing-target [] {
  if not ($"($REPO)/flake.nix" | path exists) { return (skip "repo flake.nix not found") }
  let r = (run-setup $"main rebuild '($REPO)' 'no-such-target-99999'")
  if $r.exit_code != 0 { fail $"failed: ($r.stderr)" }
  if not ($r.stdout | str contains "No 'no-such-target-99999' entry") {
    fail $"missing hint: ($r.stdout)"
  }
}

# ──────────────────────────────────────────────
# Full run with a fake $HOME
# ──────────────────────────────────────────────

def test-full-run [] {
  if (which nixos-rebuild | is-empty) { return (skip "not on NixOS") }
  if (which git | is-empty) { return (skip "git not found") }

  let sb = (make-sandbox)
  let home = $"($sb.root)/home"
  let repo = $"($home)/.nix-config"
  mkdir $repo
  git-init $repo
  touch $"($repo)/flake.nix"

  let r = (run-script
    ["--target" "testhost" "--skip-clone" "--skip-label" "--skip-rebuild"]
    --with ((sandbox-env $sb) | merge {HOME: $home}))

  let vars = if ($"($repo)/vars.nix" | path exists) { open --raw $"($repo)/vars.nix" } else { "" }
  let hw_exists = ($"($repo)/hosts/testhost/hardware-configuration.nix" | path exists)
  let staged = (^git -C $repo diff --cached --name-only | lines)
  rm -rf $sb.root

  if $r.exit_code != 0 { fail $"exit ($r.exit_code): ($r.stderr)" }
  if not ($vars | str contains $"homeDirectory = \"($home)\";") { fail "vars.nix missing fake HOME" }
  if not $hw_exists { fail "hardware-configuration.nix not generated" }
  if not ("vars.nix" in $staged) { fail "vars.nix not staged" }
  if not ($r.stdout | str contains "Setup Complete") { fail "missing completion message" }
}

def test-flake-has-nixos-configurations [] {
  let flake = $"($REPO)/flake.nix"
  if not ($flake | path exists) { return (skip "repo flake.nix not found") }
  if not (open --raw $flake | str contains "nixosConfigurations") {
    fail "missing nixosConfigurations in flake.nix"
  }
}

# ──────────────────────────────────────────────
# Runner
# ──────────────────────────────────────────────

# Show this help
def "main help" [] { help main }

# Run the setup.nu test suite in isolated temp directories
def main [] {
  let tests = [
    [group, name, run];
    ["unit", "--help", {|| test-help }]
    ["unit", "repo-dir", {|| test-repo-dir }]
    ["unit", "has-cmd", {|| test-has-cmd }]
    ["unit", "get-hostname", {|| test-get-hostname }]
    ["unit", "confirm-prompt without TTY", {|| test-confirm-no-tty }]
    ["vars", "fresh directory", {|| test-vars-fresh }]
    ["vars", "overwrite declined", {|| test-vars-overwrite-declined }]
    ["vars", "overwrite accepted", {|| test-vars-overwrite-accepted }]
    ["prerequisites", "missing flake.nix", {|| test-prereq-missing-flake }]
    ["prerequisites", "with flake.nix", {|| test-prereq-with-flake }]
    ["host-dir", "fresh host", {|| test-host-dir-fresh }]
    ["host-dir", "hardware-only", {|| test-host-dir-hardware-only }]
    ["host-dir", "keeps existing configuration.nix", {|| test-host-dir-keeps-configuration }]
    ["git", "add-to-git stages files", {|| test-add-to-git }]
    ["rebuild", "missing target prints hint", {|| test-rebuild-missing-target }]
    ["integration", "full run with fake HOME", {|| test-full-run }]
    ["integration", "flake.nix has nixosConfigurations", {|| test-flake-has-nixos-configurations }]
  ]

  print "\n=== Running setup.nu tests ===\n"

  mut results = []
  mut group = ""
  for t in $tests {
    if $t.group != $group {
      $group = $t.group
      print $"($group):"
    }
    let outcome = try {
      let out = (do $t.run)
      if ($out | describe) == "string" and ($out | str starts-with "skip: ") {
        {status: "skip", detail: ($out | str replace "skip: " "")}
      } else {
        {status: "pass", detail: ""}
      }
    } catch { |e|
      {status: "fail", detail: $e.msg}
    }
    match $outcome.status {
      "pass" => { print $"  (ansi green)✓(ansi reset) ($t.name)" }
      "skip" => { print $"  (ansi yellow)⚠(ansi reset) ($t.name) — skipped: ($outcome.detail)" }
      _ => { print $"  (ansi red)✗(ansi reset) ($t.name)\n      ($outcome.detail)" }
    }
    $results = ($results | append $outcome.status)
  }

  let passed = ($results | where $it == "pass" | length)
  let skipped = ($results | where $it == "skip" | length)
  let failed = ($results | where $it == "fail" | length)
  print $"\n=== ($passed) passed, ($skipped) skipped, ($failed) failed ===\n"
  if $failed > 0 { exit 1 }
}
