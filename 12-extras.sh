#!/usr/bin/env bash
# 12-extras.sh - suggested extras: gh CLI, NVIDIA drivers, pre-commit, bat/eza,
# PyCharm Community Edition (snap), kubectl, k9s, helm, httpie, gnome-tweaks,
# flameshot, timeshift, ssh-agent snippet
set -euo pipefail

echo "==> [12-extras-extras] Installing apt extras"
sudo apt-get update -y
# tmux installed idempotently (00-base also installs it)
command -v tmux >/dev/null 2>&1 || sudo apt-get install -y tmux
sudo apt-get install -y gnome-tweaks flameshot timeshift httpie

echo "==> [12-extras-extras] Installing gh CLI (GitHub official apt repo)"
if ! command -v gh >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      sudo gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
  fi
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y gh
fi

echo "==> [12-extras-extras] Installing bat and eza"
if ! command -v batcat >/dev/null 2>&1; then
  sudo apt-get install -y bat || sudo apt-get install -y batcat || echo "WARN: bat install failed"
fi
# friendly alias in zsh (Ubuntu ships the binary as batcat)
if [ -f "$HOME/.zshrc" ] && ! grep -qF "alias bat=" "$HOME/.zshrc" && command -v batcat >/dev/null 2>&1; then
  echo "alias bat=batcat" >> "$HOME/.zshrc"
fi
# eza: official GPG repo (the old 'exa' apt package is unmaintained)
if ! command -v eza >/dev/null 2>&1; then
  sudo mkdir -p /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/gierens.gpg ]; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
      sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg || echo "WARN: could not fetch eza key"
  fi
  if [ -f /etc/apt/keyrings/gierens.gpg ]; then
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
      sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -y && sudo apt-get install -y eza || echo "WARN: eza install failed; see https://github.com/eza-community/eza"
  fi
fi

echo "==> [12-extras-extras] Installing pre-commit (via pipx)"
command -v pre-commit >/dev/null 2>&1 || pipx install pre-commit || \
  echo "WARN: pre-commit install failed; make sure 02-python-virtualenv.sh ran (pipx)"

echo "==> [12-extras-extras] Installing PyCharm Community Edition (snap)"
command -v pycharm >/dev/null 2>&1 || command -v pycharm-community >/dev/null 2>&1 || \
  sudo snap install pycharm-community --classic || \
  echo "WARN: PyCharm CE snap failed; install via JetBrains Toolbox instead"

echo "==> [12-extras-extras] NVIDIA drivers (ubuntu-drivers autoinstall)"
if ! lspci 2>/dev/null | grep -qi 'nvidia'; then
  echo "-- No NVIDIA GPU detected, skipping."
elif command -v nvidia-smi >/dev/null 2>&1; then
  echo "-- NVIDIA driver already present (nvidia-smi works)."
else
  sudo ubuntu-drivers autoinstall || \
    echo "WARN: autoinstall failed; run 'ubuntu-drivers devices' and install a recommended driver manually."
fi

echo "==> [12-extras-extras] Installing kubectl (official apt repo)"
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update -y
command -v kubectl >/dev/null 2>&1 || sudo apt-get install -y kubectl

echo "==> [12-extras-extras] Installing k9s (binary release)"
if ! command -v k9s >/dev/null 2>&1; then
  K9S_VER="$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)"
  curl -fsSL -o /tmp/k9s.deb "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_linux_amd64.deb" && \
    sudo dpkg -i /tmp/k9s.deb || echo "WARN: k9s install failed; get it from https://github.com/derailed/k9s/releases"
  rm -f /tmp/k9s.deb
fi

echo "==> [12-extras-extras] Installing helm (official script)"
command -v helm >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "==> [12-extras-extras] ssh-agent snippet for .zshrc"
if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
fi
if ! grep -qF "ssh-agent snippet" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'

# --- ssh-agent snippet: start agent once, add default key if it exists ---
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent -t 12h > "$HOME/.ssh-agent-env" 2>/dev/null || true
fi
if [ -f "$HOME/.ssh-agent-env" ]; then
  source "$HOME/.ssh-agent-env" > /dev/null
fi
[ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
[ -f "$HOME/.ssh/id_rsa" ] && ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null
EOF
fi

echo "==> [12-extras-extras] fzf shell integration check"
grep -qF 'source /usr/share/doc/fzf/examples/key-bindings.zsh' "$HOME/.zshrc" 2>/dev/null || \
  echo '# fzf key bindings: source /usr/share/doc/fzf/examples/key-bindings.zsh' >> "$HOME/.zshrc" || true

echo "==> [12-extras-extras] Done."
