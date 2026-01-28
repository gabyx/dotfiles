#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

function gabyx::compress_pdf() {
    local file="$1"
    local output="$2"
    local level="${3:-screen}"

    if [[ ! $level =~ (screen|ebook|prepress|default) ]]; then
        gabyx::print_error "The level must be something of 'screen|ebook|prepress|default'." >&2
        return 1
    fi

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        "-dPDFSETTINGS=/$level" \
        -dNOPAUSE \
        -dBATCH \
        "-sOutputFile=$output" "$file"
}
