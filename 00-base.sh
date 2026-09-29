#!/usr/bin/env bash
# 00-base.sh - Base packages and apt update for a fresh Ubuntu dev machine (22.04/24.04)
set -euo pipefail

echo "==> [00-base] apt update + upgrade"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "==> [00-base] Installing base packages"
sudo apt-get install -y \
  curl wget git build-essential ca-certificates gnupg jq \
  htop btop tmux fzf ripgrep fd-find unzip software-properties-common \
  apt-transport-https

# On Ubuntu, the 'fd' binary from fd-find is installed as 'fdfind' to avoid a clash.
# Symlink it to 'fd' in ~/.local/bin so muscle memory / scripts using `fd` work.
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1 && [ ! -e "$HOME/.local/bin/fd" ]; then
  ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
  echo "==> [00-base] Symlinked fdfind -> ~/.local/bin/fd"
fi

echo "==> [00-base] Done."
