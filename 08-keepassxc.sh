#!/usr/bin/env bash
# 08-keepassxc.sh - KeePassXC local password manager (available in Ubuntu universe repo)
set -euo pipefail

echo "==> [08-keepassxc-keepassxc] Installing keepassxc via apt"
sudo apt-get update -y
sudo apt-get install -y keepassxc

# Optional newer builds exist in an external PPA; the universe package is fine for most.
# sudo add-apt-repository -y ppa:phoerious/keepassxc && sudo apt-get update && sudo apt-get install -y keepassxc

echo "==> [08-keepassxc-keepassxc] Done."
