#!/usr/bin/env bash

create_cache() {
    CACHE="${XDG_CACHE_HOME:-"$HOME/.cache"}/lf/thumb.$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' \
        -- "$(readlink -f "$1" || realpath "$1")" |
        sha256sum |
        cut -d' ' -f1)"
}

# Display an image with certain path, width, height, x, y
# Usage: image "$path_to_image" "$width" "$height" "$x" "$y" "$fallback_path
function image() {
    if [ -n "$TMUX" ]; then
        echo "Preview with Sixel does not work in tmux. Start in normal terminal."
    fi
    chafa -f sixel -s "$2x$3" --animate false "$1"
}

function mime_preview() {
    # The 'ran_guard' variable is there in case I need to do recursion
    # because the initial mime_type variable wasn't enough to determine
    # an adequate preview
    case "$mime_type","$ran_guard" in
    image/svg+xml,0 | image/svg,0)
        create_cache "$1"
        [ -f "$CACHE.png" ] ||
            rsvg-convert -o "$CACHE.png" -a -w "1000" -b '#1f2430' "$1"
        image "$CACHE.png" "$2" "$3" "$4" "$5" "$1"
        ;;
    image/*,0)
        image "$1" "$2" "$3" "$4" "$5" "$1"
        ;;
    audio/*,[01])
        exiftool -j "$1" | jq -C
        ;;
    video/webm,0)
        # file --mime-type doesn't distinguish well between "video/webm"
        # actual webm videos or webm audios, but exiftool does, thus
        # re-run this function with new mimetype
        mime_type="$(exiftool -s3 -MIMEType "$1")" \
        ran_guard=$((ran_guard + 1))
        mime_preview "$@"
        ;;
    video/*,[01])
        create_cache "$1"
        [ -f "$CACHE" ] ||
            ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0
        image "$CACHE" "$2" "$3" "$4" "$5" "$1"
        ;;
    */pdf,0 | */postscript,0) # .pdf, .ps
        create_cache "$1"
        [ -f "$CACHE.jpg" ] ||
            pdftoppm -jpeg -f 1 -singlefile "$1" "$CACHE"
        image "$CACHE.jpg" "$2" "$3" "$4" "$5" "$1"
        ;;
    text/*,0 | */xml,0 | application/javascript,0 | application/x-subrip,0)
        bat --terminal-width "$(($4 * 7 / 9))" -f "$1" --style=numbers
        ;;
    application/json,0)
        jq -C <"$1"
        ;;
    application/zip,0 | application/x-7z-compressed,0)
        atool --list -- "$1"
        ;;
    application/pgp-encrypted,0)
        # TODO: add lf command to decrypt it and show the decrypted file in preview window
        printf "PGP armored ASCII \033[1;31mencrypted\033[m file,\ntry using gpg to decrypt it\n\n"
        cat "$1"
        ;;
    application/octet-stream,0)
        #extension="${1##*.}" extension="${extension%"$1"}"
        case "${1##*.}" in
        gpg)
            printf "OpenPGP \033[1;31mencrypted\033[m file,\ntry using gpg to decrypt it\n\n"
            ;;
        *) exiftool -j "$1" | jq -C ;;
        esac
        ;;
    esac
    return 1
}

function main() {
    mime_type="$(file --dereference -b --mime-type -- "$1")"
    ran_guard=0
    mime_preview "$@" || return $?
}

main "$@" || exit $?
