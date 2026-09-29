#!/usr/bin/env bash
# install-all.sh - master runner. Runs each step, records pass/fail, continues on errors.
# NOTE: intentionally NOT set -e; each script traps its own fatal errors.

ask_sudo() {
  echo "==> Requesting sudo credentials up-front (avoids repeated prompts)"
  sudo -v
  ( while true; do sudo -n true 2>/dev/null && sleep 50; exit 0; done ) & SUDO_KEEPALIVE_PID=$!
}
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

ask_sudo

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS=(00-base.sh 01-fonts.sh 02-vim.sh 03-oh-my-zsh.sh 04-python-virtualenv.sh \
       05-node-npx.sh 06-vpn-support.sh 07-sublime-text.sh 08-keepassxc.sh \
       09-browsers.sh 10-docker-arvan.sh 11-cursor.sh 12-extras.sh)

declare -a RESULTS=()
for step in "${STEPS[@]}"; do
  echo ""
  echo "========================================================"
  echo "==> SECTION: $step"
  echo "========================================================"
  if bash "$DIR/$step"; then
    RESULTS+=("PASS  $step")
  else
    RESULTS+=("FAIL  $step (exit $?)")
  fi
done

echo ""
echo "===================== SUMMARY =========================="
for r in "${RESULTS[@]}"; do echo "$r"; done
echo "========================================================"
echo "Re-run any failed step individually, e.g.: bash 10-docker-arvan.sh"
