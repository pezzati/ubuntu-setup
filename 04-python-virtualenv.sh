#!/usr/bin/env bash
# 04-python-virtualenv.sh - python tooling + virtualenvwrapper wired into .zshrc
set -euo pipefail

echo "==> [04-python-python] Installing python3, pip, venv, pipx, virtualenv, virtualenvwrapper"
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv python3-pipx \
  virtualenv virtualenvwrapper

# pipx ensurepath is idempotent
pipx ensurepath 2>/dev/null || true

if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
fi

VENV_BLOCK='
# --- virtualenvwrapper ---
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="$(command -v python3)"
export VIRTUALENVWRAPPER_VIRTUALENV="$(command -v virtualenv || echo /usr/local/bin/virtualenv)"
source "$(command -v virtualenvwrapper.sh || echo /usr/share/virtualenvwrapper/virtualenvwrapper.sh)"
'
if ! grep -qF "virtualenvwrapper" "$HOME/.zshrc"; then
  printf '%s\n' "$VENV_BLOCK" >> "$HOME/.zshrc"
  echo "==> [04-python-python] virtualenvwrapper config appended to .zshrc"
else
  echo "==> [04-python-python] virtualenvwrapper already configured in .zshrc"
fi
echo "==> [04-python-python] Done."
