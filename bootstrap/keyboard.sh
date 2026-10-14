#!/usr/bin/env bash
# Point KMonad at this machine's internal keyboard and enable it.
# The repo keymap matches the MacBook Air. Another machine gets a copy.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

log() { printf '==> %s\n' "$*"; }

if [ "$(uname -s)" != "Linux" ]; then
  log "keyboard setup is Linux-only"
  exit 0
fi

detected=""
shopt -s nullglob
for dev in /dev/input/by-path/*spi*-event-kbd; do
  detected=$dev
  break
done
if [ -z "$detected" ]; then
  for dev in /dev/input/by-path/*-event-kbd; do
    detected=$dev
    break
  done
fi
shopt -u nullglob

if [ -z "$detected" ]; then
  log "no keyboard event device; skipped kmonad"
  exit 0
fi

repo_kbd="$ROOT/keyboard/mba.kbd"
repo_path=$(sed -n 's/.*device-file "\([^"]*\)".*/\1/p' "$repo_kbd" | head -1)
if [ -z "$repo_path" ]; then
  echo "keyboard/mba.kbd has no device-file" >&2
  exit 1
fi

sudo mkdir -p /etc/kmonad
if [ "$detected" = "$repo_path" ]; then
  sudo ln -sfn "$repo_kbd" /etc/kmonad/mba.kbd
  log "kmonad uses the repo keymap ($detected)"
else
  sed "s|$repo_path|$detected|" "$repo_kbd" | sudo tee /etc/kmonad/mba.kbd >/dev/null
  log "wrote /etc/kmonad/mba.kbd for $detected"
  log "keyboard/mba.kbd in the repo still describes the MacBook Air"
fi

if ! command -v kmonad >/dev/null 2>&1; then
  log "kmonad is not installed yet; skipped the service"
  exit 0
fi

sudo systemctl enable kmonad@mba.service
if [ "$detected" = "$repo_path" ]; then
  sudo systemctl start kmonad@mba.service
else
  sudo systemctl restart kmonad@mba.service
fi
log "kmonad@mba is enabled"
