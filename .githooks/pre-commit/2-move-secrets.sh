#!/usr/bin/env bash

set -e
set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
COMP_DIR="$ROOT_DIR/components"

just move-all-to-secrets
git add "$COMP_DIR/secrets"
