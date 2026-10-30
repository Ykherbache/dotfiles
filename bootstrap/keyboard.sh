#!/usr/bin/env bash
# Fedora Asahi: KMonad on the internal keyboard and plugged-in USB keyboards.
# Ubuntu: keyd instead. The repo keymap matches the MacBook Air.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
KMONAD_VERSION=0.4.5
KMONAD_BIN=/usr/local/bin/kmonad

log() { printf '==> %s\n' "$*"; }

if [ "$(uname -s)" != "Linux" ]; then
  log "keyboard setup is Linux-only"
  exit 0
fi

log "installing gnome-ws"
sudo install -m 755 "$ROOT/keyboard/gnome-ws" /usr/local/bin/gnome-ws

# keyd's overload is enough for "H is Hyper". KMonad's tap macros are not.
if [ -r /etc/os-release ] && grep -q '^ID=ubuntu$' /etc/os-release; then
  log "installing keyd"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y keyd
  sudo mkdir -p /etc/keyd
  sudo cp "$ROOT/keyboard/keyd.conf" /etc/keyd/default.conf
  while read -r unit _; do
    [ -n "$unit" ] || continue
    sudo systemctl disable --now "$unit" || true
    log "stopped $unit"
  done < <(systemctl list-units 'kmonad@*' --all --no-legend || true)
  sudo systemctl enable --now keyd
  sudo systemctl restart keyd
  if [ -n "${USER:-}" ] && [ "$USER" != root ]; then
    sudo usermod -aG keyd "$USER"
    log "added $USER to the keyd group; log out once so the pointer label can read keyd"
  fi
  log "keyd is enabled"
  exit 0
fi

# Internal keyboards only. USB event-kbd nodes include external keyboards
# and mice, so they are not a fallback.
detected=""
shopt -s nullglob
for dev in /dev/input/by-path/*spi*-event-kbd; do
  detected=$dev
  break
done
if [ -z "$detected" ] && [ -e /dev/input/by-path/platform-i8042-serio-0-event-kbd ]; then
  detected=/dev/input/by-path/platform-i8042-serio-0-event-kbd
fi
if [ -z "$detected" ]; then
  for dev in /dev/input/by-path/platform-i8042-serio-*-event-kbd; do
    detected=$dev
    break
  done
fi
if [ -z "$detected" ]; then
  echo "no internal keyboard (SPI or i8042); not grabbing a USB keyboard" >&2
  found=0
  for dev in /dev/input/by-path/*-event-kbd; do
    echo "  $dev" >&2
    found=1
  done
  shopt -u nullglob
  if [ "$found" -eq 0 ]; then
    echo "  (no /dev/input/by-path/*-event-kbd)" >&2
  fi
  exit 1
fi
shopt -u nullglob

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

# Fedora Asahi installs kmonad with dnf. Ubuntu has no package; the 0.4.5
# GitHub asset is a static x86-64 binary and matches the unit's path.
if [ ! -x "$KMONAD_BIN" ] && ! command -v kmonad >/dev/null 2>&1; then
  if [ "$(uname -m)" != "x86_64" ]; then
    log "kmonad is not installed yet; skipped the service"
    exit 0
  fi
  log "installing kmonad $KMONAD_VERSION"
  sudo curl -fsSL -o "$KMONAD_BIN" \
    "https://github.com/kmonad/kmonad/releases/download/${KMONAD_VERSION}/kmonad"
  sudo chmod 755 "$KMONAD_BIN"
fi

if [ -x "$KMONAD_BIN" ]; then
  sudo cp "$ROOT/keyboard/kmonad@.service" /etc/systemd/system/kmonad@.service
  sudo systemctl daemon-reload
elif ! command -v kmonad >/dev/null 2>&1; then
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

# External USB keyboards get the same keymap in their own instance.
# Only the main interface: by-id names with -ifNN are mice or media keys.
usb_marker=";; usb keyboard written by bootstrap/keyboard.sh"
repo_sink=$(sed -n 's/.*uinput-sink "\([^"]*\)".*/\1/p' "$repo_kbd" | head -1)
usb_names=()
shopt -s nullglob
for dev in /dev/input/by-id/usb-*-event-kbd; do
  base=$(basename "$dev")
  case $base in
    *-if[0-9]*) continue ;;
  esac
  name=$(printf '%s\n' "${base#usb-}" | sed 's/-event-kbd$//' \
    | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-' \
    | awk -F- '{out=""; prev=""; for (i = 1; i <= NF; i++) { if ($i != "" && $i != prev) { out = out (out == "" ? "" : "-") $i; prev = $i } } print out}')
  [ -n "$name" ] && [ "$name" != "mba" ] || continue
  usb_names+=("$name")
  {
    printf '%s\n' "$usb_marker"
    sed -e "s|$repo_path|$dev|" -e "s|\"$repo_sink\"|\"KMonad $name\"|" "$repo_kbd"
  } | sudo tee "/etc/kmonad/$name.kbd" >/dev/null
  sudo systemctl enable "kmonad@$name.service"
  sudo systemctl restart "kmonad@$name.service"
  log "kmonad@$name is enabled for $dev"
done

for kbd in /etc/kmonad/*.kbd; do
  name=$(basename "$kbd" .kbd)
  [ "$name" = "mba" ] && continue
  sudo head -1 "$kbd" | grep -qxF "$usb_marker" || continue
  case " ${usb_names[*]} " in
    *" $name "*) continue ;;
  esac
  sudo systemctl disable --now "kmonad@$name.service" || true
  sudo rm -f "$kbd"
  log "removed kmonad@$name (keyboard not connected)"
done
shopt -u nullglob
