#!/usr/bin/env bash
# GNOME workspaces, terminals, and extensions from this machine.
# Safe to re-run. Extension download failures are reported, not fatal.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

log() { printf '==> %s\n' "$*"; }

distro=unknown
if [ -r /etc/os-release ]; then
  distro=$(. /etc/os-release && printf '%s' "${ID:-unknown}")
fi

if ! command -v gsettings >/dev/null 2>&1; then
  echo "gsettings is missing; this script is for GNOME." >&2
  exit 1
fi

bind() {
  gsettings set org.gnome.desktop.wm.keybindings "$1" "$2"
}

log "workspaces and Hyper shortcuts"
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 13
bind switch-to-workspace-1 "['<Super>Home', '<Shift><Super>a']"
bind switch-to-workspace-2 "['<Shift><Super>s']"
bind switch-to-workspace-3 "['<Shift><Super>d']"
bind switch-to-workspace-4 "['<Shift><Super>f']"
bind switch-to-workspace-5 "['<Shift><Super>g']"
bind switch-to-workspace-6 "['<Shift><Super>z']"
bind switch-to-workspace-7 "['<Shift><Super>x']"
bind switch-to-workspace-8 "['<Shift><Super>c']"
bind switch-to-workspace-9 "['<Shift><Super>v']"
bind switch-to-workspace-10 "['<Shift><Super>q']"
bind switch-to-workspace-11 "['<Shift><Super>w']"
bind switch-to-workspace-12 "['<Shift><Super>e']"
bind switch-to-workspace-last "['<Super>End', '<Shift><Super>r']"
bind move-to-workspace-1 "['<Super><Shift>Home', '<Shift><Alt><Super>a']"
bind move-to-workspace-2 "['<Shift><Alt><Super>s']"
bind move-to-workspace-3 "['<Shift><Alt><Super>d']"
bind move-to-workspace-4 "['<Shift><Alt><Super>f']"
bind move-to-workspace-5 "['<Shift><Alt><Super>g']"
bind move-to-workspace-6 "['<Shift><Alt><Super>z']"
bind move-to-workspace-7 "['<Shift><Alt><Super>x']"
bind move-to-workspace-8 "['<Shift><Alt><Super>c']"
bind move-to-workspace-9 "['<Shift><Alt><Super>v']"
bind move-to-workspace-10 "['<Shift><Alt><Super>q']"
bind move-to-workspace-11 "['<Shift><Alt><Super>w']"
bind move-to-workspace-12 "['<Shift><Alt><Super>e']"
bind move-to-workspace-last "['<Super><Shift>End', '<Shift><Alt><Super>r']"
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

log "Tilix profile"
# Ptyxis only stores window size and a generated profile id here, so it is left alone.
dconf load / < "$ROOT/gnome/terminals.dconf"

log "masking the file indexers"
systemctl --user mask localsearch-3.service tracker-miner-fs-3.service \
  || log "could not mask the file indexers"

# background-logo ships with Fedora Workstation, so it is not downloaded.
# The last two are installed but not enabled.
download_extensions=(
  workspaces-by-open-apps@favo02.github.com
  impatience@gfxmonk.net
  ram_sens@mosazghi
)
extra_extensions=(
  improved-workspace-indicator@michaelaquilina.github.io
  statistig@mustafaaycll.github.io
)
enabled_extensions=("${download_extensions[@]}")
case $distro in
  fedora|fedora-asahi-remix)
    enabled_extensions=(background-logo@fedorahosted.org "${enabled_extensions[@]}")
    ;;
esac

install_extension() {
  local uuid=$1 shell_major info url tmp
  shell_major=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)
  if ! info=$(curl -fsSL -A 'Mozilla/5.0' \
      "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_major}"); then
    log "could not look up $uuid"
    return 1
  fi
  if ! url=$(python3 - "$info" "$shell_major" "$uuid" <<'PY'
import json, sys
info, shell_major, uuid = sys.argv[1:]
data = json.loads(info)
versions = data.get("shell_version_map") or {}
entry = versions.get(shell_major)
if entry is None:
    majors = sorted((key for key in versions if key.isdigit()), key=int)
    compatible = [key for key in majors if int(key) <= int(shell_major)]
    entry = versions[compatible[-1]] if compatible else None
if entry is None:
    raise SystemExit(1)
print(
    "https://extensions.gnome.org/download-extension/%s.shell-extension.zip?version_tag=%s"
    % (uuid, entry["pk"])
)
PY
  ); then
    log "no build of $uuid for GNOME $shell_major"
    return 1
  fi
  tmp=$(mktemp)
  if ! curl -fsSL -A 'Mozilla/5.0' -o "$tmp" "$url"; then
    rm -f "$tmp"
    log "download failed for $uuid"
    return 1
  fi
  if ! gnome-extensions install --force "$tmp"; then
    rm -f "$tmp"
    log "install failed for $uuid"
    return 1
  fi
  rm -f "$tmp"
  log "installed $uuid"
}

failed=()
if ! command -v gnome-extensions >/dev/null 2>&1 || ! command -v gnome-shell >/dev/null 2>&1; then
  log "gnome-extensions is missing; install these from https://extensions.gnome.org :"
  printf '  %s\n' "${download_extensions[@]}" "${extra_extensions[@]}"
else
  for uuid in "${download_extensions[@]}" "${extra_extensions[@]}"; do
    install_extension "$uuid" || failed+=("$uuid")
  done
fi

if [ "$distro" = "ubuntu" ]; then
  hint_uuid=keyd-layer-hint@dotfiles
  hint_dest="${HOME}/.local/share/gnome-shell/extensions/${hint_uuid}"
  mkdir -p "$hint_dest"
  cp -a "$ROOT/gnome/${hint_uuid}/." "$hint_dest/"
  enabled_extensions+=("$hint_uuid")
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions enable "$hint_uuid" \
      || log "log out once so $hint_uuid can load"
  fi
fi

quoted=$(printf "'%s', " "${enabled_extensions[@]}")
gsettings set org.gnome.shell enabled-extensions "[${quoted%, }]"

if [ "${#failed[@]}" -gt 0 ]; then
  log "still missing; install these from https://extensions.gnome.org :"
  printf '  %s\n' "${failed[@]}"
fi

log "GNOME settings applied"
