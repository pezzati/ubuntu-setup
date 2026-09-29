#!/usr/bin/env bash
# 05-node-npx.sh - nvm + latest LTS Node.js (npx ships with npm/node)
set -euo pipefail

echo "==> [05-node-node] Installing nvm"
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm" --depth=1
  (cd "$HOME/.nvm" && git fetch --tags && git checkout "$(git describe --tags "$(git rev-list --tags --max-count=1)")")
else
  echo "==> [05-node-node] nvm already installed"
fi

# Add nvm init lines to .zshrc if missing
if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
fi
if ! grep -qF 'NVM_DIR' "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'EOF'

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
fi

echo "==> [05-node-node] Installing latest LTS node (includes npm + npx)"
export NVM_DIR="$HOME/.nvm"
\. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
nvm alias default lts/*
echo "==> [05-node-node] Done: node $(node -v), npm $(npm -v), npx $(npx -v)"
