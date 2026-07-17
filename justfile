set positional-arguments
set dotenv-load := true
set shell := ["nu", "--no-config-file", "-c"]
root_dir := justfile_directory()
build_dir := root_dir / "build"

mod vm "./tools/just/vm.just"

# The host for which most commands work below.
default_host := env("NIXOS_HOST", "not-defined")
yubikey_name := env("YUBIKEY_NAME", "normal")

# If the nix-output-monitor should be used.
use_nom := env("USE_NOM", "true")

# Default command to list all commands.
list:
    just --list

# Enter a development shell to ensure all tools are here.
alias dev := develop
develop *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        let flake_dir = "."
        let shell = "default"
        let cmd = if ($args | is-empty) {
            [ env $"SHELL=($env.SHELL)" $env.SHELL ]
        } else {
            $args
        }
        ^nix develop --accept-flake-config $"($flake_dir)#($shell)" --command ...$cmd
    }

# Format the whole repository.
format:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^nix fmt ...$args
    }

# Eval the NixOS toplevel.
eval *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        let host = "{{default_host}}"
        let cmd = [
            eval
            --verbose
            --show-trace
            $".#nixosConfigurations.($host).config.system.build.toplevel"
        ] | append $args

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        if "{{use_nom}}" == "true" {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }

# Build the NixOS.
build *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        let host = "{{default_host}}"
        let cmd = [
            build
            --verbose
            --show-trace
            $".#nixosConfigurations.($host).config.system.build.toplevel"
        ] | append $args

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        if "{{use_nom}}" == "true" {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }

# Build a host image (no submodules / secrets).
build-image *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        let host = "{{default_host}}"
        let package = $"($host)-image"
        let cmd = [
            build
            --verbose
            --show-trace
            $".#($package)"
        ] | append $args

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        if "{{use_nom}}" == "true" {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }

# Show NixOS options for a certain host.
option opts *args:
    #!/usr/bin/env nu
    def main [opts: string, ...args: string] {
        ^nixos-option -F ".#{{default_host}}" $opts ...$args
    }

## Flake maintenance commands =================================================
# Update the flake lock file. Use arguments to specify single inputs.
update *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        cd "{{root_dir}}"
        ^nix flake update ...$args
    }

## NixOS Commands to execute on NixOS systems =================================
# Prints the NixOS version (based on nixpkgs repository).
version:
    nixos-version --revision

# Build the new configuration and set it the boot default.
boot *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^just rebuild boot ...$args
    }

# Switch the host to the latest configuration.
switch *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^just rebuild switch ...$args --show-trace --verbose
        ^just diff
    }

# Build with nix-output-monitor, then switch.
switch-visual *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^just use_nom=true build

        print "============= SWITCHING ============="
        ^just rebuild switch --show-trace --verbose ...$args

        ^just diff
    }

# Switch to the latest configuration but under boot entry `name`.
switch-test name="test" *args:
    #!/usr/bin/env nu
    def main [name: string = "test", ...args: string] {
        ^just rebuild switch -p $name --show-trace --verbose ...$args
        ^just diff $name
    }

# Build the host and put it under the boot entry `name`.
boot-test name="test" *args:
    #!/usr/bin/env nu
    def main [name: string = "test", ...args: string] {
        ^just rebuild boot -p $name --show-trace --verbose ...$args
        ^just diff $name
    }

# NixOS rebuild command for the host (defined in the flake).
rebuild how *args:
    #!/usr/bin/env nu
    def --wrapped main [how: string, ...args: string] {
        cd "{{root_dir}}"

        let host = "{{default_host}}"
        let cmd = [
            --sudo
            $how
            --flake $".#($host)"
        ] | append $args

        print "Checkout all LFS files."
        ^git lfs checkout
        print "Fetch all submodules."
        ^git submodule update --recursive --init

        print "----"
        print $"nixos-rebuild ($cmd | str join ' ')"
        print "----"

        ^nixos-rebuild ...$cmd
    }

# Show the history of the system profile and test profiles.
history:
    #!/usr/bin/env nu
    def main [] {
        print "History in 'system' profile:"
        ^nix profile history --profile /nix/var/nix/profiles/system

        if ("/nix/var/nix/profiles/system-profiles/test" | path exists) {
            print "History in 'test' profile:"
            ^nix profile history --profile /nix/var/nix/profiles/system-profiles/test
        }

        if ("/nix/var/nix/profiles/system-profiles/music" | path exists) {
            print "History in 'music' profile:"
            ^nix profile history --profile /nix/var/nix/profiles/system-profiles/music
        }
    }

# Run the trim script to reduce the amount of generations kept on the system.
# Usage with `--help`.
trim *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^./tools/scripts/trim-generations.sh ...$args
    }

# Diff the generation at index `index` with the last one.
# `last` and `current` can be a number (newest = 0) or a path to a profile link.
diff profile_name="system" current="0" last="1":
    #!/usr/bin/env nu
    def sort-profiles [profile_name: string] {
        let match = if ($profile_name =~ "system") {
            $".*/profiles/($profile_name)-[^/]+$"
        } else {
            $".*/system-profiles/($profile_name)-[^/]+$"
        }

        print $match

        (
            (do -i {ls /nix/var/nix/profiles/*} | default []) ++
            (do -i {ls /nix/var/nix/profiles/system-profiles/*} | default [])
        )
        | where type == symlink
        | where name =~ $match
        | sort-by modified --reverse
        | get name
    }

    def main [
        profile_name: string = "system"
        current: string = "0"
        last: string = "1"
    ] {
        if (which nvd | is-empty) {
            print -e "! Command 'nvd' not installed to print difference."
            return
        }

        let profiles = (sort-profiles $profile_name)
        if ($profiles | is-empty) {
            error make $"No profiles with name '($profile_name)-*' found."
        } else {
            print "Profiles found:" $profiles
        }

        mut $current = $current
        mut idx = try { $current | into int } catch { null }
        if $idx != null {
            $current = $profiles | get $idx
        }

        mut last_profile = $last
        mut idx = try { $last | into int } catch { null }
        if $idx != null {
            $last_profile = $profiles | get $idx
        }

        let map_to_current = { |p|
            if ($p | path expand) == ("/run/current-system" | path expand) {
                "/run/current-system"
            } else {
                $p
            }
        }

        $current = do $map_to_current $current
        $last_profile = do $map_to_current $last_profile

        ^nvd diff $last_profile $current
    }

# Diff closures from `dest_ref` to `src_ref`. This builds and
# computes the closure which might take some time.
diff-closure dest_ref="/" src_ref="origin/main" host=default_host:
    #!/usr/bin/env nu
    def main [
        dest_ref: string = "/"
        src_ref: string = "origin/main"
        host: string = "{{default_host}}"
    ] {
        print $"Diffing closures of host '($host)' from '($src_ref)' to '($dest_ref)'"

        ^nix store diff-closures $".?ref=($src_ref)#nixosConfigurations.($host).config.system.build.toplevel" $".?ref=($dest_ref)#nixosConfigurations.($host).config.system.build.toplevel"
    }

# Run nix-tree to get the tree of all packages.
tree *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^nix-tree ...$args
    }

# Run Nix garbage-collection on the system-profile.
gc:
    #!/usr/bin/env nu
    def rm-rf [pattern: string] {
        let matches = (do --ignore-errors { glob $pattern })
        if ($matches | is-not-empty) {
            ^sudo rm -rf ...$matches
        }
    }

    def main [] {
        print "Remove test profile"
        rm-rf "/nix/var/nix/profiles/system-profiles/test"
        rm-rf "/nix/var/nix/profiles/system-profiles/test-*"

        print "Remove steam profile"
        rm-rf "/nix/var/nix/profiles/system-profiles/steam"
        rm-rf "/nix/var/nix/profiles/system-profiles/steam-*"

        print "Remove all generations older than 60 days"
        ^sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 60d
        ^sudo nix profile wipe-history --profile /nix/var/nix/profiles/music

        print "Garbage collect all unused nix store entries"
        ^sudo nix store gc --debug
    }

# Start the NixOS VM.
start host="vm" remote_viewer="false":
    #!/usr/bin/env nu
    def main [host: string = "vm", remote_viewer: string = "false"] {
        let host = if ($host | is-empty) { "{{default_host}}" } else { $host }

        let out_dir = $"{{build_dir}}/($host)"
        mkdir $out_dir

        let cmd = [
            build
            --out-link $"($out_dir)/vmWithDisko"
            --show-trace
            --verbose
            --log-format internal-json
            $"{{root_dir}}#nixosConfigurations.($host).config.system.build.vmWithDisko"
        ]

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        ^nix ...$cmd o+e>| nom --json

        let qemu_args = if $remote_viewer == "true" {
            print "IMPORTANT: ----------------------"
            print $"IMPORTANT: Connect with 'remote-viewer spice+unix://($out_dir)/spice.sock'"
            print "IMPORTANT: ----------------------"
            [
                "-spice" $"unix=on,addr=($out_dir)/spice.sock,disable-ticketing=on"
                "-device" "virtio-serial-pci"
                "-chardev" "spicevmc,id=ch1,name=vdagent"
                "-device" "virtserialport,chardev=ch1,name=com.redhat.spice.0"
            ]
        } else {
            [ "-display" "gtk,gl=on" ]
        }

        let vm_bin = $"($out_dir)/vmWithDisko/bin/disko-vm"
        if not ($vm_bin | path exists) {
            print $"Host '($host)' not built. Use 'just build'."
        }

        print $"Starting with '($vm_bin)'"

        # FIXME: Forward qemu opts like this: https://github.com/nix-community/disko/pull/1142
        with-env { QEMU_OPTS: ($qemu_args | str join ' ') } {
            ^$vm_bin
        }
    }

# Diff current branch against origin/main.
diff-to-main:
    git fetch origin; git diff "origin/main...HEAD"

# Apply all configs, also encrypted ones.
apply-configs *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^just cm apply ...$args
    }

# Apply all configs but not encrypted ones.
apply-configs-exclude-encrypted *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        ^chezmoi -S "." apply --exclude encrypted ...$args
    }

# Encrypt a file using the encryption configured in `.chezmoi.yaml`.
# This is using the public key.
[no-cd]
encrypt file:
    #!/usr/bin/env nu
    def main [file: string] {
        ^just cm encrypt $file
    }

# Decrypt a file using the encryption configured.
# You need `store-keyfile-private-key` executed.
[no-cd]
decrypt file:
    #!/usr/bin/env nu
    def main [file: string] {
        ^just cm decrypt $file
    }

# Decrypt and edit the file.
# You need `store-keyfile-private-key` executed.
[no-cd]
decrypt-edit file:
    #!/usr/bin/env nu
    def main [file: string] {
        ^just cm edit $file
    }

# Move all regular files in the repo to the secret folder.
move-all-to-secrets:
    #!/usr/bin/env nu
    def main [] {
        # Remove all links, recreate them from secrets.
        ^fd '.*.age$' -E 'secrets/**' --type l --exec rm '{}'

        ^fd '.*.age|identity$' --type f ./secrets --exec just create-links-from-secrets '{}'

        ^fd '.*.age$' -E 'secrets/**' --type f --exec just move-to-secrets '{}'
    }

# Move a file to the secrets folder.
[private]
move-to-secrets file:
    #!/usr/bin/env nu
    def main [file: string] {
        let raw_d = ($file | path dirname)
        let d = if ($raw_d | is-empty) { "." } else { $raw_d }

        mkdir $"secrets/($d)"
        cp $file $"secrets/($file)"
        rm $file

        let points_to = (^realpath --relative-to $d $"secrets/($file)" | str trim)
        ^ln -s $points_to $file
    }

# Align file name of link to secrets.
[private]
create-links-from-secrets file:
    #!/usr/bin/env nu
    def main [file: string] {
        let file_rel = ($file | str replace --regex '^.*?secrets/' '')
        let link = $file_rel

        let raw_d = ($file_rel | path dirname)
        let d = if ($raw_d | is-empty) { "." } else { $raw_d }

        let points_to = (^realpath --relative-to $d $file | str trim)

        let link_dir = ($link | path dirname)
        if ($link_dir | is-not-empty) {
            mkdir $link_dir
        }

        # Only add the link if there is no such file existing.
        # If it exists we re-added it in chezmoi.
        if not ($link | path exists) {
            ^ln -s $points_to $link
        }
    }

# Wrapper to `chezmoi` which provides the necessary encryption key
# temporarily and deletes it afterwards again.
# Only used for invocations which need the private key.
[no-cd]
cm *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        let key = $"($env.HOME)/.config/chezmoi/key"
        mkdir $"($env.HOME)/.config/chezmoi"

        # Emulate `trap cleanup EXIT`: always remove the key on the way out.
        let cleanup = {|| rm --force $key }

        try {
            if (($env.NO_ENCRYPTION_SETUP? | default "") == "true") {
                print "Skip encryption setup."
            } else {
                let k = (
                    ^"{{root_dir}}/nix/pkgs/scripts/shell/common/get-secret.sh"
                        --bw-id "3cc1b9eb-2504-4cec-8dda-b17501145099"
                        --yubikey "{{yubikey_name}}"
                        --prompt "Chezmoi encryption age identity: "
                        --file $"($env.HOME)/.config/chezmoi/key"
                )
                $k | save --force --raw $key
            }

            print "Running chezmoi ..."
            ^chezmoi -S "." ...$args
            print "Chezmoi done."

            if ($args | any {|a| $a =~ "re-add" }) {
                print "Re-add detected, running 'just move-all-to-secrets'"
                ^just move-all-to-secrets
            }
        } catch {|err|
            do $cleanup
            error make { msg: $"cm failed: ($err.msg)" }
        }

        do $cleanup
    }

# Like `cm` but with no encryption.
cmn *args:
    #!/usr/bin/env nu
    def main [...args: string] {
        with-env { NO_ENCRYPTION_SETUP: "true" } {
            ^just cm --exclude encrypted ...$args
        }
    }

# Delete the script state of chezmoi to rerun scripts.
delete-chezmoi-script-state:
    chezmoi -S "." state delete-bucket --bucket scriptState
