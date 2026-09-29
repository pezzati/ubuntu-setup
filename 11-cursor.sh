#!/usr/bin/env bash
# 11-cursor.sh - Cursor AI code editor installed via npx
#               (npx @anysphere/cursor-appimage - the official npm install method).
# Requires node/npx from 05-node-npx.sh.
# Idempotent: skips install if the AppImage already exists.
set -euo pipefail

LOCALBIN="$HOME/.local/bin"
APPDIR="$HOME/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
CURSOR_APPIMAGE="$APPDIR/cursor.appimage"
DESKTOP_FILE="$DESKTOP_DIR/cursor.desktop"
mkdir -p "$LOCALBIN" "$APPDIR" "$DESKTOP_DIR"

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx not found. Run 05-node-npx.sh first (or: source ~/.nvm/nvm.sh)." >&2
  exit 1
fi

echo "==> [11-cursor] Installing Cursor via npx (@anysphere/cursor-appimage)"
if [ -x "$CURSOR_APPIMAGE" ]; then
  echo "-- Cursor AppImage already present at $CURSOR_APPIMAGE, skipping install"
else
  # Official npm installer: downloads the Cursor AppImage and installs it.
  npx --yes @anysphere/cursor-appimage
  # Ensure the AppImage exists at our known path (installer may place it elsewhere).
  if [ ! -x "$CURSOR_APPIMAGE" ]; then
    found="$(find "$HOME" -maxdepth 3 -name 'cursor*.AppImage' -o -name 'cursor.appimage' 2>/dev/null | head -n1 || true)"
    if [ -n "$found" ]; then
      mv "$found" "$CURSOR_APPIMAGE"
      chmod +x "$CURSOR_APPIMAGE"
    else
      echo "ERROR: AppImage not found after npx install. Run manually: npx @anysphere/cursor-appimage" >&2
      exit 1
    fi
  fi
fi

echo "==> [11-cursor] Creating 'cursor' launcher in $LOCALBIN"
if [ ! -e "$LOCALBIN/cursor" ] || [ "$(readlink -f "$LOCALBIN/cursor")" != "$(readlink -f "$CURSOR_APPIMAGE")" ]; then
  ln -sf "$CURSOR_APPIMAGE" "$LOCALBIN/cursor"
fi

echo "==> [11-cursor] Creating .desktop entry at $DESKTOP_FILE"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor
Exec=$CURSOR_APPIMAGE --no-sandbox
Icon=code
Type=Application
Categories=Development;IDE;
Terminal=false
EOF
chmod +x "$DESKTOP_FILE" 2>/dev/null || true

echo "==> [11-cursor] Done. Launch from your app menu or run: cursor"
echo "-- (If it doesn't launch, try running with --no-sandbox.)"
