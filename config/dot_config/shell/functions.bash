#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091

eval "$(gabyx::shell-source)" || {
    echo "Could not 'eval \$(gabyx::source)'."
} >&2
