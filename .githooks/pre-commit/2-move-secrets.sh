#!/usr/bin/env bash

set -e
set -u

just move-all-to-secrets
git add secrets
