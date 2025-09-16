#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_COMMON:-}" != "loaded" ]; then
    source "$GABYX_LIB_DIR/common/log.sh"

    GABYX_LIB_COMMON=loaded
fi
