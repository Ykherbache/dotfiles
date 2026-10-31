#!/usr/bin/env bash
# KDE Plasma desktops, Hyper shortcuts, and terminal profile. Mirrors bootstrap/gnome.sh.
# Safe to re-run. Log out and back in afterwards so kglobalaccel and the keyboard reload.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

log() { printf '==> %s\n' "$*"; }

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  echo "kwriteconfig6 is missing; this script is for KDE Plasma 6." >&2
  exit 1
fi

shortcut() {
  local action=$1 keys=$2
  kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "$action" "$keys,none,$action"
  live_shortcut "$action" "$keys"
}

# In a running Plasma 6 session, kglobalaccel lives inside KWin and writes its own state back
# over kglobalshortcutsrc, so the file alone does not rebind keys until the next login.
live_shortcut() {
  local action=$1 keys=$2 code=0 part list='@a(ai) []'
  command -v gdbus >/dev/null 2>&1 || return 0
  if [ "$keys" != none ]; then
    local parts
    IFS=+ read -ra parts <<< "$keys"
    for part in "${parts[@]}"; do
      case $part in
        Meta) code=$((code | 0x10000000)) ;;
        Ctrl) code=$((code | 0x04000000)) ;;
        Alt) code=$((code | 0x08000000)) ;;
        Shift) code=$((code | 0x02000000)) ;;
        *) code=$((code | $(printf '%d' "'$part"))) ;;
      esac
    done
    list="[([$code, 0, 0, 0],)]"
  fi
  gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
    --method org.kde.KGlobalAccel.setForeignShortcutKeys \
    "['kwin', '$action', 'KWin', '$action']" "$list" >/dev/null 2>&1 || true
}

reload_kwin() {
  dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure \
    >/dev/null 2>&1 || log "could not reload KWin"
}

log "move-and-follow KWin script"
scripts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts"
mkdir -p "$scripts_dir"
ln -sfn "$ROOT/kde/kwin/move-and-follow" "$scripts_dir/move-and-follow"
kwriteconfig6 --file kwinrc --group Plugins --key move-and-followEnabled true
ln -sfn "$ROOT/kde/kwin/layer-hint" "$scripts_dir/layer-hint"
kwriteconfig6 --file kwinrc --group Plugins --key layer-hintEnabled true

log "workspaces and Hyper shortcuts"
kwriteconfig6 --file kwinrc --group Desktops --key Number 13
kwriteconfig6 --file kwinrc --group Desktops --key Rows 1
# The script has to be loaded before its shortcuts can be rebound live.
reload_kwin

# Same order as keyboard/mba.kbd. KDE has a real desktop 13, so R needs no "last" trick.
letters=(A S D F G Z X C V Q W E R)
for i in "${!letters[@]}"; do
  n=$((i + 1))
  shortcut "Switch to Desktop $n" "Meta+Ctrl+Alt+Shift+${letters[$i]}"
  # KDE's own move action leaves you behind; kde/kwin/move-and-follow switches with the window.
  shortcut "Window to Desktop $n" "none"
  shortcut "Move Window and Follow to Desktop $n" "Meta+Alt+Shift+${letters[$i]}"
done

log "panel: numbered pager with app icons, RAM percentage"
dbus-send --session --type=method_call --dest=org.kde.plasmashell /PlasmaShell \
  org.kde.PlasmaShell.evaluateScript string:"$(cat "$ROOT/kde/plasma/panel.js")" \
  >/dev/null 2>&1 || log "could not update the panel; run bootstrap/kde.sh again from a Plasma session"

log "animations off"
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0
# Off on their own too, so desktop switches stay instant if the global speed changes.
kwriteconfig6 --file kwinrc --group Plugins --key slideEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key desktopchangeosdEnabled false

log "file indexers off"
balooctl6 disable >/dev/null 2>&1 \
  || kwriteconfig6 --file baloofilerc --group "Basic Settings" --key Indexing-Enabled false
systemctl --user mask localsearch-3.service >/dev/null 2>&1 || log "could not mask localsearch"

log "Caps Lock as Escape"
kwriteconfig6 --file kxkbrc --group Layout --key Options caps:escape
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true

if command -v dconf >/dev/null 2>&1; then
  log "Tilix profile"
  dconf load / < "$ROOT/gnome/terminals.dconf" || log "could not load the Tilix profile"
fi

reload_kwin

log "pointer label"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$unit_dir"
ln -sfn "$ROOT/keyboard/kde-layer-hint.service" "$unit_dir/kde-layer-hint.service"
systemctl --user daemon-reload
systemctl --user enable kde-layer-hint.service
systemctl --user restart kde-layer-hint.service \
  || log "could not start the pointer label"

log "KDE settings applied. Log out and back in if a shortcut or Caps Lock does not work yet."
