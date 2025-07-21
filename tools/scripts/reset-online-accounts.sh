#!/usr/bin/env bash

set -u
set -e
set -o pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)

rm -rf ~/.config/evolution || true
rm -rf ~/.local/share/evolution || true

systemctl --user stop evolution-addressbook-factory.service
systemctl --user stop evolution-calendar-factory.service
systemctl --user stop evolution-source-registry.service
systemctl --user daemon-reload

echo "Apply evolution configs, press enter:"
read -r

sed -i -E \
    -e "s@^.config/evolution/sources@# .config/evolution/sources@" \
    -e "s@^.config/goa-1@# .config/goa-1@" \
    "$ROOT_DIR/config/.chezmoiignore"

just cm init
just cm apply

find ~/.config/evolution/sources -type f -name "*.source" -print0 |
    xargs -0 -I {} sed -i -E "s@NeedsInitialSetup=false@NeedsInitialSetup=true@" {}

# rm ~/.config/chezmoi/chezmoistate.boltdb

sed -i -E \
    -e "s@^# .config/evolution/sources@.config/evolution/sources@" \
    -e "s@^# .config/goa-1@.config/goa-1@" \
    "$ROOT_DIR/config/.chezmoiignore"

echo "Restart dbus-broker (logout), press enter:"
read -r
systemctl --user restart dbus-broker
