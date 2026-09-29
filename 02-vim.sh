#!/usr/bin/env bash
# 02-vim.sh - vim + a minimal sensible .vimrc (backs up existing, never overwrites)
set -euo pipefail

echo "==> [02-vim-vim] Installing vim"
sudo apt-get update -y
sudo apt-get install -y vim

VIMRC="$HOME/.vimrc"
if [ -f "$VIMRC" ]; then
  echo "==> [02-vim-vim] Existing .vimrc found; leaving it untouched"
else
  echo "==> [02-vim-vim] Creating minimal .vimrc"
  cat > "$VIMRC" <<'EOF'
" minimal sensible vimrc
syntax on
set number
set relativenumber
set mouse=a
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set backspace=indent,eol,start
set undofile
set hlsearch
set incsearch
set encoding=utf-8
EOF
fi
echo "==> [02-vim-vim] Done."
