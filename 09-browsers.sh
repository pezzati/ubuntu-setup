#!/usr/bin/env bash
# 09-browsers.sh - Google Chrome + Firefox
set -euo pipefail

echo "==> [09-browsers-browsers] Installing Google Chrome (official .deb)"
if ! command -v google-chrome-stable >/dev/null 2>&1; then
  TMP_DEB="$(mktemp /tmp/chrome-XXXX.deb)"
  wget -q --show-progress -O "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  sudo apt-get install -y "$TMP_DEB" || sudo dpkg -i "$TMP_DEB" || { sudo apt-get update -y && sudo apt-get -f install -y; }
  rm -f "$TMP_DEB"
else
  echo "==> [09-browsers-browsers] Chrome already installed"
fi

echo "==> [09-browsers-browsers] Installing Firefox"
# NOTE: On Ubuntu 22.04+ Firefox is a snap by default; `apt install firefox` just installs
# the snap transition package. That is acceptable - the command below works on both.
sudo apt-get update -y
sudo apt-get install -y firefox || sudo snap install firefox
echo "==> [09-browsers-browsers] Done."
