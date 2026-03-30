#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153
# This script gets a secret (Bitwarden id `bw_id`):
#
# - If a Yubikey is present:
#   From the `enc_file` which is a FIDO age encrypted file
#   for Yubikey with name `yubikey_name`.
#   If it does not exist it will be created by requesting
#   the secret either from Bitwarden or
#   prompting for it.
#   Later invocations when the Yubikey is present
#
# - Other wise from Bitwarden or prompted.

set -eu
set -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/log.sh"

function get_bitwarden() {
    [ -n "$1" ] || return 1
    gabyx::print_info "Getting secret '$1' from Bitwarden."
    if command -v bw &>/dev/null && [ -n "${BW_SESSION:-}" ]; then
        gabyx::print_debug "Bitwarden session present."
        bw get password "$1"
        return 0
    fi
    return 1
}

function get_prompt() {
    read -s -r -p "$1" k
    echo >/dev/tty
    [ -n "$k" ] || return 1
    echo "$k" && return 0
}

declare -A bw_fido_age
bw_fido_age["normal"]="cc76135e-8375-490f-b884-b41a013aa9c5"
bw_fido_age["s1"]="14c8d52d-0f1f-4584-b1b4-b41a013ce86a"
bw_fido_age["s2"]="4d5af98d-1792-47f6-b4c7-b41a013d00b3"

bw_id="${1:-}"
yubikey_name="${2:-$YUBIKEY_NAME}"
prompt="$3"
enc_file="$4-$yubikey_name.age-fido"

if [ -n "$(ykman list)" ]; then
    gabyx::print_info "Yubikey seems present."

    fido_identity="$HOME/.local/share/chezmoi/secrets/config/dot_config/age/private_gabyx-$yubikey_name-fido2-hmac.identity"
    if [ ! -f "$fido_identity" ]; then
        gabyx::print_info "FIDO2 age identity '$fido_identity' not existing."
        fido_identity=$(
            get_bitwarden "${bw_fido_age["$yubikey_name"]}" ||
                get_prompt "Enter FIDO2 age identity created with Yubikey '$yubikey_name': "
        )
    else
        fido_identity=$(cat "$fido_identity")
    fi

    if [ ! -f "$enc_file" ]; then
        gabyx::print_info "Writing '$enc_file' for Yubikey '$yubikey_name' further invocations."

        mkdir -p "$(dirname "$enc_file")"
        k=$(get_bitwarden "$bw_id") || k=$(get_prompt "$prompt") ||
            gabyx::die "Could not get secret from Bitwarden or prompt."

        gabyx::print_info "Writing file '$enc_file'."
        echo "$k" | age -e -i <(echo "$fido_identity") >"$enc_file" || {
            rm -f "$enc_file" &>/dev/null || true
            gabyx::die "Could not encrypt to '$enc_file'."
        }
        chmod 400 "$enc_file"
    fi

    # Now we can decrypt over Yubikey
    age -d -i <(echo "$fido_identity") "$enc_file" ||
        gabyx::die "Decrypting '$enc_file' failed."
else
    gabyx::print_info "No Yubikey present."
    k=$(get_bitwarden "$bw_id") || k=$(get_prompt "$prompt") ||
        gabyx::die "Could not get secret from Bitwarden or prompt."
    echo "$k"
fi

gabyx::print_info "Secret retrieved."
