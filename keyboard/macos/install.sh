#!/usr/bin/env bash
set -u
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo "Copying 'Programmer.bundle' to '/Library/Keyboard Layouts'."
sudo cp -r "$SCRIPT_DIR/Programmer.bundle" "/Library/Keyboard Layouts/"
echo 'Install complete!'
echo 'Please enable Programmer Qwerty in Keyboard Input Sources then logoff/login again. Enjoy!'
