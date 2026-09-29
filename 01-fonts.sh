#!/usr/bin/env bash
# 01-fonts.sh - Nerd Fonts: MesloLGS NF (Powerlevel10k recommended), 4 variants
#               (Regular, Bold, Italic, Bold Italic) from romkatv/powerlevel10k-media.
# Idempotent: skips files that already exist; safe to re-run.
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
MESLO_DIR="$FONT_DIR/MesloLGS NF"
BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
MESLO_FILES=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)

# Ensure fontconfig (fc-cache) is available
if ! command -v fc-cache >/dev/null 2>&1; then
  echo "==> [01-fonts] Installing fontconfig"
  sudo apt-get update -y && sudo apt-get install -y fontconfig
fi

mkdir -p "$MESLO_DIR"

echo "==> [01-fonts] Installing MesloLGS NF (4 variants) into $MESLO_DIR"
for f in "${MESLO_FILES[@]}"; do
  dest="$MESLO_DIR/$f"
  url="$BASE_URL/$(printf '%s' "$f" | sed 's/ /%20/g')"
  if [ -s "$dest" ]; then
    echo "-- $f already installed, skipping"
  else
    echo "-- downloading $f"
    curl -fSL --retry 3 -o "$dest" "$url"
  fi
done

echo "==> [01-fonts] Refreshing font cache"
fc-cache -fv "$FONT_DIR"

echo "==> [01-fonts] Installed fonts found by fontconfig:"
fc-list 2>/dev/null | grep -i 'MesloLGS' | sort -u || \
  echo "WARN: no MesloLGS fonts found by fc-list; verify files in $FONT_DIR"

echo "==> [01-fonts] Done. Select 'MesloLGS NF' in your terminal font settings."
