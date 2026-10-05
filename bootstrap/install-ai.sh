#!/usr/bin/env bash
# Cursor, Claude Code, and opencode. Run bootstrap/install.sh first.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OS=$(uname -s)

log() { printf '==> %s\n' "$*"; }

install_claude() {
  if command -v claude >/dev/null 2>&1; then
    log "claude is already installed"
  else
    log "installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  cat <<'EOF'

Sign in with `claude`, then install the plugins from this Mac:
  /plugin marketplace add omc
  /plugin marketplace add pbakaus/impeccable
  /plugin install oh-my-claudecode@omc
  /plugin install impeccable@impeccable
  /plugin install posthog@claude-plugins-official
  /plugin install frontend-design@claude-plugins-official

EOF
}

install_opencode() {
  if command -v opencode >/dev/null 2>&1; then
    log "opencode is already installed"
    return 0
  fi
  log "installing opencode"
  curl -fsSL https://opencode.ai/install | bash
}

install_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    log "rtk is already installed"
    return 0
  fi
  if [ "$OS" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    brew install rtk
    return 0
  fi
  cat <<'EOF'
rtk is not installed. Claude Code still runs: the hook skips rtk when it is missing.
To install it on Linux: cargo install --git https://github.com/rtk-ai/rtk
EOF
}

cursor_download_url() {
  local platform=$1
  curl -fsSL "https://cursor.com/api/download?platform=${platform}&releaseTrack=stable" | python3 -c '
import json, sys
data = json.loads(sys.stdin.read())
urls = []
def walk(node):
    if isinstance(node, dict):
        for value in node.values():
            walk(value)
    elif isinstance(node, list):
        for value in node:
            walk(value)
    elif isinstance(node, str) and node.startswith("http"):
        urls.append(node)
walk(data)
for url in urls:
    if "AppImage" in url:
        print(url)
        raise SystemExit(0)
if urls:
    print(urls[0])
else:
    raise SystemExit(1)
'
}

install_cursor_linux() {
  if command -v cursor >/dev/null 2>&1; then
    log "cursor is already on PATH"
    return 0
  fi
  local platform arch url dest
  arch=$(uname -m)
  case $arch in
    aarch64|arm64) platform=linux-arm64 ;;
    x86_64) platform=linux-x64 ;;
    *)
      echo "No Cursor build for $arch" >&2
      return 1
      ;;
  esac
  mkdir -p "$HOME/Applications" "$HOME/.local/bin" "$HOME/.local/share/applications"
  dest="$HOME/Applications/cursor.AppImage"
  if [ ! -x "$dest" ]; then
    log "downloading Cursor AppImage ($platform)"
    url=$(cursor_download_url "$platform")
    curl -fL "$url" -o "$dest"
    chmod +x "$dest"
  fi
  cat > "$HOME/.local/bin/cursor" <<EOF
#!/bin/sh
exec "\$HOME/Applications/cursor.AppImage" "\$@"
EOF
  chmod +x "$HOME/.local/bin/cursor"
  cat > "$HOME/.local/share/applications/cursor.desktop" <<EOF
[Desktop Entry]
Name=Cursor
Comment=Cursor editor
Exec=$HOME/Applications/cursor.AppImage %F
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
EOF
  cat <<'EOF'

If Cursor closes immediately on Asahi, the 16K kernel page size is the usual cause.
Edit ~/.local/bin/cursor and add --no-sandbox before "$@".
If it still fails, use Neovim and Claude Code instead.

EOF
}

install_claude
install_opencode
install_rtk
if [ "$OS" = "Linux" ]; then
  install_cursor_linux
  if command -v cursor >/dev/null 2>&1; then
    while IFS= read -r ext; do
      [ -z "$ext" ] && continue
      cursor --install-extension "$ext" || true
    done < "$ROOT/cursor/extensions.txt"
  fi
fi

log "AI tools step finished. Sign in to Cursor, Claude Code, and opencode."
echo "In Neovim, run :Copilot auth once."
