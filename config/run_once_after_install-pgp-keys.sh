#!/usr/bin/env bash

set -e
set -u
set -o pipefail

REPO_DIR="$CHEZMOI_WORKING_TREE"

if ! command -v gpg &>/dev/null; then
    echo "WARNING: 'gnupg' is not installed. Cannot install PGP keys." >&2
    exit 0
fi

cd "$REPO_DIR" || {
    echo "Could not cd to '$REPO_DIR'."
    exit 1
}

# Collect all GPG keys deployed on the system.
readarray -t private_files < <(find ~/.config/gnupg -type f -name "*-private.asc.age")

trusted_keys=(
    90AECCB97AD34CE43AED9402E969172AB0757EB8
    F24F52A877FC8A640A836E1DF9E3B0FF9D4E7A81
    C2F8DE28F8AB11118966910837A5F59C07097058
)

for private_file in "${private_files[@]}"; do
    echo
    echo "Install Private PGP key: '$private_file' ..."

    public_file="${private_file%%-private.asc.age}-public.asc"
    passphrase_file="${private_file%%.asc.age}.passphrase.age"

    # Import private key.
    gpg --import \
        --passphrase-file <(just cm decrypt "$passphrase_file") \
        --pinentry-mode loopback --armor \
        <(just cm decrypt "$private_file") || {
        echo "WARNING: Import of PGP file '$private_file' failed." >&2
        exit 1
    }

    # Import public key.
    echo "Install Public PGP key: '$public_file' ..."
    gpg --import \
        --pinentry-mode loopback --armor \
        "$public_file" || {
        echo "WARNING: Import of PGP file '$public_file' failed." >&2
        exit 1
    }

    # Trust all imported keys with trust level 5.
    trusted_re="$(printf "%s|" "${trusted_keys[@]}")"
    trusted_re="${trusted_re%|}"
    echo "Setting trust level for know keys."
    gpg --list-keys --fingerprint | grep pub -A 1 | grep -Ev "pub|--" | tr -d ' ' | grep -E "$trusted_re" |
        awk 'BEGIN { FS = "\n" } ; { print $1":5:" } ' |
        gpg --import-ownertrust
done

echo "Successfully installed all GPG keys."
echo
