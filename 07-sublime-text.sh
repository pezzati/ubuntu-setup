#!/usr/bin/env bash
# 07-sublime-text.sh - Sublime Text 4 via official apt repo
set -euo pipefail

echo "==> [07-sublime-sublime] Adding Sublime HQ GPG key + repo"
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/sublimehq-pub.gpg ]; then
  curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/sublimehq-pub.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" | \
  sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null

echo "==> [07-sublime-sublime] Installing sublime-text"
sudo apt-get update -y
sudo apt-get install -y sublime-text
echo "==> [07-sublime-sublime] Done."
