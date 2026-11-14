# @fish-lsp-disable 2002 4004

# If the devshell isn't active, the functions defined in this file cannot be
# used, so ensure that the dev environment is always active.
if not set -q IN_NIX_CONFIG_DEVSHELL
    alias devshell "nix develop"
    return 1
end

#
# --- Private utility functions
#

function _pretty_print
    set colored_command (string escape -- $argv | string join ' ' | fish_indent --ansi)
    echo "$(set_color brgreen --bold)~~>$(set_color normal) $colored_command"
end

function _run
    _pretty_print $argv
    $argv
end

function _require
    for program in $argv
        if not command -vq $program
            echo "Required program '$program' is missing. Ensure it is in your environment, then try again."
        end
    end
end

#
# --- Commands
#

set -g this_host (hostname -s)

function dry -d "Dry-run a function (replaces _run with _pretty_print)"
    functions --erase _run
    functions --copy _pretty_print _run

    # Mistakenly ran this function without any arguments, print functions.
    if not set -q argv[1]
        run
        return
    end

    $argv
end

function check-applied -d "Check if the currently applied configuration needs to be updated"
    set last_commit_timestamp (git log -1 --format=%at)
    set current_commit_pretty (set_color --dim --italics)$NIX_CONFIG_REV(set_color normal)
    if test $NIX_CONFIG_LAST_MODIFIED -lt $last_commit_timestamp
        echo "Configuration is out of date."
        echo $current_commit_pretty
        return 1
    else
        set commit_hash (git log -1 --format=%H)
        if test $NIX_CONFIG_REV = $commit_hash
            echo "Configuration is the most recent commit."
            echo $current_commit_pretty
        else
            echo "Current configuration is dirty (new)."
            echo $current_commit_pretty
        end
    end
end

function edit-age -d "Edit the encrypted files stored in nix-secrets"
    set -l secrets_dir ""
    if test -d "$HOME/Developer/nix-secrets"
        set secrets_dir "$HOME/Developer/nix-secrets"
    else if test -d "../nix-secrets"
        set secrets_dir "../nix-secrets"
    end

    if test -n "$secrets_dir"
        set file (fd --type file --glob '*.age' . $secrets_dir | fzf --height=40% --layout=reverse)
        or return
        pushd $secrets_dir
        if test -f agenix-rules.nix
            set -lx AGENIX_RULES "$PWD/agenix-rules.nix"
        else if test -f secrets.nix
            set -lx AGENIX_RULES "$PWD/secrets.nix"
        end
        agenix -e (path resolve $file) $argv
        popd
    else
        set file (fd --type file --glob '*.age' | fzf --height=40% --layout=reverse)
        or return
        if test -f agenix-rules.nix
            set -lx AGENIX_RULES "$PWD/agenix-rules.nix"
        else if test -f secrets.nix
            set -lx AGENIX_RULES "$PWD/secrets.nix"
        end
        agenix -e $file $argv
    end
end

function build-oci-image -d "Build the OCI Ampere A1 qcow2 custom image for nixos"
    _run nix build .#nixosConfigurations.nixos.config.system.build.OCIImage -L $argv
end

function import-oci-image -d "Upload and import the built OCI qcow2 custom image into Oracle Cloud"
    _require oci-import-image
    set img (realpath result/nixos-image-oci-*.qcow2 2>/dev/null | head -n1)
    if not test -n "$img"
        echo "No built qcow2 found in result/. Run 'run build-oci-image' first or pass the qcow2 path directly."
        return 1
    end
    _run oci-import-image $img $argv
end

function install-oci -d "Install NixOS on an OCI instance via nixos-anywhere + nixos-images kexec"
    if not set -q argv[1]
        echo "Usage: run install-oci <user@oracle-ip> [extra-args...]"
        return 1
    end
    set target $argv[1]
    _run nixos-anywhere \
        --kexec "https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-aarch64-linux.tar.gz" \
        --build-on remote \
        --flake .#nixos \
        $target $argv[2..]
end

function deploy-vpnpack -d "Build and deploy vpn-pack to UniFi Cloud Gateway via SSH"
    if not set -q argv[1]
        echo "Usage: run deploy-vpnpack <user@unifi-ip | unifi-ip> [--reauth] [extra-nix-build-args...]"
        return 1
    end
    set -l target $argv[1]
    if not string match -q "*@*" $target
        set target "root@$target"
    end

    set -l reauth false
    set -l nix_build_args
    for arg in $argv[2..]
        if test $arg = --reauth
            set reauth true
        else
            set --append nix_build_args $arg
        end
    end

    _run nix build .#vpn-pack $nix_build_args
    or return 1

    set -l tarball (realpath result/vpn-pack.tar.gz 2>/dev/null; or realpath result/vpn-pack-*.tar.gz 2>/dev/null | head -n1)
    if not test -n "$tarball"
        echo "Error: built vpn-pack tarball not found in result/"
        return 1
    end

    set -l tarball_name (basename $tarball)
    _run scp $tarball "$target:/root/"
    or return 1

    _run ssh $target "cd /root && rm -rf vpn-pack && tar xzf $tarball_name && cd vpn-pack && bash install.sh"
    or return 1

    # Check for tailscale-unifi.age secret to auto-authenticate
    set -l secret_file ""
    if test -f "$HOME/Developer/nix-secrets/secrets/tailscale-unifi.age"
        set secret_file "$HOME/Developer/nix-secrets/secrets/tailscale-unifi.age"
    else if test -f "../nix-secrets/secrets/tailscale-unifi.age"
        set secret_file "../nix-secrets/secrets/tailscale-unifi.age"
    else if test -f "secrets/tailscale-unifi.age"
        set secret_file "secrets/tailscale-unifi.age"
    end

    if test -n "$secret_file"
        set -l identity ""
        if test -f "$HOME/.ssh/id_ed25519"
            set identity "$HOME/.ssh/id_ed25519"
        else if test -f /etc/ssh/ssh_host_ed25519_key
            set identity /etc/ssh/ssh_host_ed25519_key
        end

        set -l authkey ""
        if test -n "$identity"; and command -vq age
            set authkey (age -d -i $identity $secret_file 2>/dev/null | string trim)
        else if test -n "$identity"; and command -vq rage
            set authkey (rage -d -i $identity $secret_file 2>/dev/null | string trim)
        end

        if test -n "$authkey"
            set -l needs_auth false
            if test $reauth = true
                set needs_auth true
            else
                if not ssh $target "/persistent/vpn-pack/bin/tailscale status >/dev/null 2>&1"
                    set needs_auth true
                end
            end

            if test $needs_auth = true
                echo (set_color green --bold)"==> Authenticating Tailscale on $target with tag:unifi..."(set_color normal)
                echo $authkey | ssh $target 'read -r k; /persistent/vpn-pack/bin/tailscale up --authkey="$k" --advertise-tags=tag:unifi --ssh --hostname=dream-router --reset'
            else
                echo (set_color cyan)"==> Tailscale is already authenticated on $target. Ensuring tag:unifi is set..."(set_color normal)
                ssh $target '/persistent/vpn-pack/bin/tailscale set --advertise-tags=tag:unifi --ssh' 2>/dev/null; or true
            end
        else
            echo (set_color yellow)"[!] Found $secret_file, but failed to decrypt using $identity."(set_color normal)
        end
    end
end

#
# --- Functions for building/switching hosts
#

function nixos -a verb
    set rebuild_args
    set maybe_sudo
    set target_verb $verb
    if test $verb = check
        set target_verb dry-build
    end

    if test $this_host != nixos
        # If not building on nixos, set nixos to be the target.
        # Otherwise, it is definitely a mistake to switch on the local system.
        set --append rebuild_args --elevate=sudo --target-host leporuid@nixos
        echo (set_color --dim --italics)"not on nixos, targeting remote host..."(set_color normal)

        # If the current system isn't aarch64 Linux, then nixos needs to build
        # its own configuration remotely. --no-reexec (--no-build-nix) is also required
        # because the local system will attempt to execute a version of `nix` that it can't run.
        if test (uname -m)-(uname -s | string lower) != aarch64-linux
            set --append rebuild_args --build-host leporuid@nixos --no-reexec
            echo (set_color --dim --italics)"not on aarch64-linux, performing remote build..."(set_color normal)
        end

    else
        # If, for whatever reason, we *are* on nixos, then we need to use sudo.
        set maybe_sudo sudo
        echo (set_color --dim --italics)"on nixos, using sudo..."(set_color normal)
    end

    _run $maybe_sudo nixos-rebuild $target_verb --flake .#nixos $rebuild_args $argv[2..]
end

function MacBook-Pro -a verb
    set maybe_sudo
    if test $verb = switch
        set maybe_sudo sudo
    else if test $verb = check
        # Fast pure evaluation check (instantiates derivation without building packages or closures)
        _run nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath $argv[2..]
        or return $status
        echo
        return 0
    end

    _run $maybe_sudo darwin-rebuild $verb --flake .#MacBook-Pro $argv[2..]
end

# The logic below defines the commands used to build/switch configurations for
# the hosts above. This requires some amount of metaprogramming, which Fish has
# decent support for.

set hosts (ls hosts)
set verbs build switch check

for host in $hosts
    functions -q $host; or continue
    functions --copy $host _$host
    functions --erase $host

    for verb in $verbs
        echo "function $verb-$host -d '$verb the configuration for $host'; _$host $verb \$argv; end" | source
        test $this_host = $host; and alias $verb-host $verb-$host
    end
end

function update-m3u8dl -d "Query latest GitHub Actions artifact ID and update pin.json"
    _require gh jq
    echo (set_color cyan)"==> Querying latest successful GitHub Actions run for nilaoda/N_m3u8DL-RE..."(set_color normal)

    set -l run_id $argv[1]
    if test -z "$run_id"
        set run_id (gh run list -R nilaoda/N_m3u8DL-RE -s success -L 1 --json databaseId -q '.[0].databaseId')
    end

    if test -z "$run_id"
        echo (set_color red)"[!] No successful Actions run found"(set_color normal)
        return 1
    end

    set -l artifact_id (gh api "repos/nilaoda/N_m3u8DL-RE/actions/runs/$run_id/artifacts" \
        | jq -r '.artifacts[] | select(.name | test("osx-arm64|mac|darwin")).id')

    if test -z "$artifact_id"
        echo (set_color red)"[!] No suitable macOS ARM64 artifact found in run $run_id"(set_color normal)
        return 1
    end

    echo (set_color green)"Found latest artifact ID: $artifact_id (from run #$run_id)"(set_color normal)
    set -l url "https://nightly.link/nilaoda/N_m3u8DL-RE/actions/artifacts/$artifact_id.zip"

    echo (set_color cyan)"==> Prefetching and computing new hash..."(set_color normal)
    set -l raw_hash (nix-prefetch-url --unpack $url 2>/dev/null)
    set -l sri_hash ""
    if test -n "$raw_hash"
        set sri_hash (nix hash to-sri --type sha256 $raw_hash 2>/dev/null)
        test -z "$sri_hash"; and set sri_hash $raw_hash
    end

    set -l pin_file "packages/n-m3u8dl-re/pin.json"
    echo "{\"runId\": \"$run_id\", \"artifactId\": \"$artifact_id\", \"hash\": \"$sri_hash\"}" | jq . >$pin_file
    echo (set_color green --bold)"Updated $pin_file to latest version."(set_color normal)
end

function fetch-facter -d "Fetch latest hardware report facter.json from remote Oracle NixOS"
    echo (set_color cyan)"==> Fetching hardware report from nixos and generating facter.json..."(set_color normal)
    ssh leporuid@nixos "sudo nixos-facter -o /tmp/facter.json"
    and scp leporuid@nixos:/tmp/facter.json hosts/nixos/facter.json
    and echo (set_color green)"Successfully updated hosts/nixos/facter.json."(set_color normal)
end
