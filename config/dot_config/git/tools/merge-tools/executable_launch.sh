#!/usr/bin/env bash
# =========================================================================================
# Chezmoi Setup
#
# @date 17.3.2023
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================

wslToWin="false"
command -v wslpath &>/dev/null && wslToWin="true"

function wrapPath() {
    file="$1"
    if [ "$wslToWin" = "true" ]; then
        if [ "$1" = "/dev/null" ]; then
            file=$(mktemp)
        fi
        wslpath -m "$file" && return
    fi
    echo "$file"
}

tool="$1"
shift

if [ "$tool" = "mergetool" ]; then
    tool=$(git config merge.tool)
fi

toolPath=$(git config "mergetool.$tool.path")
useUnixVariant=$(git config "mergetool.$tool.useUnixVariant")
[ "$useUnixVariant" = "true" ] && tool="$tool-unix"

base="$(wrapPath "$1")"
local=$(wrapPath "$2")
remote=$(wrapPath "$3")
merged=$(wrapPath "$4")

if [ "$tool" = "bcompare" ]; then
    "$toolPath" /lefttitle="Mine[$local]" /righttitle="Theirs[$remote]" /centertitle="Base[$base]" /outputtitle="Merged[$merged]" /automerge /reviewconflicts "$remote" "$local" "$base" "$merged"
elif [ "$tool" = "bcompare-unix" ]; then
    "$toolPath" -lefttitle="Mine[$local]" -righttitle="Theirs[$remote]" -centertitle="Base[$base]" -outputtitle="Merged[$merged]" -automerge -reviewconflicts "$remote" "$local" "$base" "$merged"
elif [ "$tool" = "edp" ]; then
    "$toolPath" -merge "-dn1:Mine[$local]" "-dn2:Base[$base]" "-dn3:Theirs[$remote]" "-dno:Merged[$merged]" -nh -o:"$merged" -- "$remote" "$base" "$local"
elif [ "$tool" = "meld" ]; then
    "$toolPath" --auto-merge "$local" "$base" "$remote" --output "$merged" --label "Merge::Local|Base|Remote"
elif [ "$tool" = "nvim" ]; then
    # wincmd w focuses the last window because $ always references the highest window number.
    # wincmd J moves the focused window to the bottom, so in this case the window for the merged file view.
    "$toolPath" -d "$local" "$remote" "$merged" -c 'wincmd w' -c 'wincmd J'
elif [ "$tool" = "vscode" ]; then
    "$toolPath" --wait -m "$local" "$remote" "$base" "$merged"
elif [ "$tool" = "vsdiffmerge" ]; then
    # git-bash.exe (MSYS) converts paths
    # https://github.com/git-for-windows/build-extra/blob/main/ReleaseNotes.md#known-issues
    MSYS_NO_PATHCONV=1 "$toolPath" "$local" "$remote" "$base" "$merged" "/t" "/m"
else
    echo "! No such merge tool '$tool' supported in 'launch.sh'" >&2
    exit 1
fi

exitCode="$?"
echo "Mergetool '$tool' ($toolPath had exit code: $exitCode" >&2

exit $exitCode
