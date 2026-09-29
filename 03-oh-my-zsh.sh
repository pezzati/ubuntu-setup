#!/usr/bin/env bash
# 03-oh-my-zsh.sh - zsh + oh-my-zsh + plugins + lightweight custom prompt
set -euo pipefail

echo "==> [03-zsh-zsh] Installing zsh"
sudo apt-get update -y
sudo apt-get install -y zsh

# Set zsh as default shell (idempotent)
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  echo "==> [03-zsh-zsh] Setting zsh as default shell (takes effect after logout/login)"
  chsh -s "$(command -v zsh)"
fi

# Backup .zshrc before we touch it
if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
fi

# Install oh-my-zsh unattended (idempotent)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> [03-zsh-zsh] Installing oh-my-zsh (unattended)"
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> [03-zsh-zsh] oh-my-zsh already installed, skipping"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Plugins (idempotent clones)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Enable plugins in .zshrc (idempotent rewrite of plugins= line)
if grep -qE '^plugins=' "$HOME/.zshrc"; then
  sed -i 's/^plugins=.*/plugins=(git kubectl docker zsh-autosuggestions zsh-syntax-highlighting fzf)/' "$HOME/.zshrc"
else
  echo 'plugins=(git kubectl docker zsh-autosuggestions zsh-syntax-highlighting fzf)' >> "$HOME/.zshrc"
fi
# NOTE: if you use k8s plugin instead of kubectl, swap the name in the line above.

# --- Lightweight custom prompt: git repo name | time | last cmd exec time ---
PROMPT_BLOCK='
# --- custom lightweight prompt (no powerlevel10k needed) ---
autoload -Uz add-zsh-hook
typeset -g CMD_EXEC_TIME=""
zmodload zsh/datetime

preexec_exec_time() {
  CMD_START_SECS=$EPOCHSECONDS
}
report_exec_time() {
  if [ -n "${CMD_START_SECS:-}" ]; then
    local d=$(( EPOCHSECONDS - CMD_START_SECS ))
    if (( d >= 1 )); then
      CMD_EXEC_TIME="%F{yellow}${d}s%F{reset}"
    else
      CMD_EXEC_TIME=""
    fi
    CMD_START_SECS=""
  fi
  RPROMPT="${CMD_EXEC_TIME} %F{cyan}%T%F{reset}"
}
set_prompt() {
  local repo=""
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo="%F{magenta}$(basename "$(git rev-parse --show-toplevel)")%F{reset}"
  fi
  PROMPT="%F{green}%n@%m%F{reset} %F{blue}%~%F{reset} ${repo} %F{yellow}\$(git_prompt_info)%F{reset}$ "
  RPROMPT="${CMD_EXEC_TIME} %F{cyan}%T%F{reset}"
}
add-zsh-hook preexec preexec_exec_time
add-zsh-hook precmd report_exec_time
set_prompt
'
if ! grep -qF "# --- custom lightweight prompt" "$HOME/.zshrc"; then
  printf '%s\n' "$PROMPT_BLOCK" >> "$HOME/.zshrc"
  echo "==> [03-zsh-zsh] Custom prompt appended to .zshrc"
fi

# OPTIONAL powerlevel10k alternative (uncomment to use instead of custom prompt):
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
# sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "==> [03-zsh-zsh] Done. Restart your terminal (or run 'exec zsh')."
