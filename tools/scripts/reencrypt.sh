#!/usr/bin/env bash
# Re-encrypt everything from
# a source private key to a new dest public key (age).

dir="$1"
source_private_key="$2"
dest_public_key="$3"

cd "$dir" || exit 1
readarray -t files < <(find . -name "*.age" -and -not -name "key*.age")

for file in "${files[@]}"; do
    echo "Re-entrypt file '$file'"

    tmp=$(mktemp)
    cp "$file" "$tmp"

    echo "$source_private_key" | age -d -i - "$tmp" |
        age -e -a -r "$dest_public_key" >"$file"

    rm -f "$tmp"
done
