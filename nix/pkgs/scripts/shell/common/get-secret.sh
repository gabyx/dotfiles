#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

set -eu
set -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/log.sh"

print_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -b, --bw-id ID           Bitwarden item ID
  -y, --yubikey NAME       Yubikey name (or use \$YUBIKEY_NAME)
  -p, --prompt TEXT        Prompt fallback text
  -f, --file PREFIX        File prefix for encrypted file
  -h, --help               Show this help message

Description:
  Retrieves a secret from Bitwarden or prompt, optionally encrypts it
  using a Yubikey-backed age identity, and decrypts it on demand.

Examples:
  $(basename "$0") -b my-secret-id -y main -f /tmp/secret
  $(basename "$0") --bw-id id --yubikey key1 --prompt "Enter secret"
EOF
}

bw_id=""
yubikey_name="${YUBIKEY_NAME:-}"
prompt=""
file_prefix=""

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -b | --bw-id)
            bw_id="$2"
            shift 2
            ;;
        -y | --yubikey)
            yubikey_name="$2"
            shift 2
            ;;
        -p | --prompt)
            prompt="$2"
            shift 2
            ;;
        -f | --file)
            file_prefix="$2"
            shift 2
            ;;
        -h | --help)
            print_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown argument: $1" >&2
            print_help
            exit 1
            ;;
        esac
    done

    if [[ -z $bw_id && -z $prompt ]]; then
        gabyx::die "Either --bw-id or --prompt must be provided."
    fi

    if [[ -z $file_prefix ]]; then
        gabyx::die "--file is required."
    fi
}

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

function main() {
    parse_args "$@"

    declare -A bw_fido_age
    bw_fido_age["normal"]="cc76135e-8375-490f-b884-b41a013aa9c5"
    bw_fido_age["s1"]="14c8d52d-0f1f-4584-b1b4-b41a013ce86a"
    bw_fido_age["s2"]="4d5af98d-1792-47f6-b4c7-b41a013d00b3"

    enc_file="${file_prefix}-${yubikey_name}.age-fido"

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
}

main "$@"
