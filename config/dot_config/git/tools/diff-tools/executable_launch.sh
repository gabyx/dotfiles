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

if [ "$tool" = "difftool" ]; then
    tool=$(git config diff.tool)
fi

toolPath=$(git config "difftool.$tool.path")
useUnixVariant=$(git config "difftool.$tool.useUnixVariant")
[ "$useUnixVariant" = "true" ] && tool="$tool-unix"

local=$(wrapPath "$1")
remote=$(wrapPath "$2")

if [ "$tool" = "bcompare" ]; then
    "$toolPath"  "$local" "$remote" /lefttitle="Original[$local]" /righttitle="Mine[$remote]"
elif [ "$tool" = "bcompare-unix" ]; then
    "$toolPath"  "$local" "$remote" -lefttitle="Original[$local]" -righttitle="Mine[$remote]"
elif [ "$tool" = "edp" ]; then
    "$toolPath" "-dn1:Diff::Original[$local]" "-dn2:Mine[$remote]" -nh -- "$local" "$remote"
elif [ "$tool" = "meld" ]; then
    "$toolPath" "$local" "$remote" --label "Diff::Original|Mine"
elif [ "$tool" = "nvim" ]; then
    "$toolPath" -d "$local" "$remote" 
elif [ "$tool" = "vscode" ]; then
    "$toolPath" --wait --diff "$local" "$remote"
elif [ "$tool" = "vsdiffmerge" ]; then
    # git-bash.exe (MSYS) converts paths
    # https://github.com/git-for-windows/build-extra/blob/main/ReleaseNotes.md#known-issues
    MSYS_NO_PATHCONV=1 "$toolPath" "$local" "$remote" /t
else
    echo "! No such diff tool '$tool' supported in 'launch.sh'" >&2
    exit 1
fi

exitCode="$?"
echo "Difftool '$tool' ($toolPath) had exit code: $exitCode" >&2

exit $exitCode
