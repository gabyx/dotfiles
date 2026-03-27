#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

# Login into the Bitwarden CLI
# and make the session variable `BW_SESSION` available.
function gabyx::bitwarden() {
    BW_SESSION=$(bw login gnuetzi@gmail.com --raw)
    export BW_SESSION
}
