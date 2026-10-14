#!/usr/bin/env bash
# Move Docker and containerd storage to a dedicated ext4 partition mounted at boot.
# Idempotent. Needs sudo.
set -euo pipefail

LABEL=${DOCKER_DISK_LABEL:-epitech eu}
MOUNT=${DOCKER_DISK_MOUNT:-/mnt/epitech-eu}
DOCKER_ROOT=$MOUNT/docker
CONTAINERD_ROOT=$MOUNT/containerd

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

DEV=$(blkid -L "$LABEL") || die "no partition labelled '$LABEL'"
UUID=$(sudo blkid -s UUID -o value "$DEV")
FSTYPE=$(sudo blkid -s TYPE -o value "$DEV")
[ "$FSTYPE" = "ext4" ] || die "$DEV is $FSTYPE, expected ext4"

# udisks mounts it under /run/media only after login; Docker needs it at boot.
current=$(findmnt -rno TARGET "$DEV" || true)
if [ -n "$current" ] && [ "$current" != "$MOUNT" ]; then
  log "unmounting $DEV from $current"
  udisksctl unmount -b "$DEV" >/dev/null 2>&1 || sudo umount "$DEV"
fi

if ! grep -q "UUID=$UUID" /etc/fstab; then
  log "adding $MOUNT to /etc/fstab"
  printf 'UUID=%s %s ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2\n' \
    "$UUID" "$MOUNT" | sudo tee -a /etc/fstab >/dev/null
fi
sudo mkdir -p "$MOUNT"
sudo systemctl daemon-reload
findmnt -rno TARGET "$MOUNT" >/dev/null || sudo mount "$MOUNT"

log "stopping docker and containerd"
sudo systemctl stop docker.socket docker.service containerd.service

copy_root() {
  local src=$1 dst=$2
  sudo mkdir -p "$dst"
  if [ -d "$src" ] && [ ! -L "$src" ] && [ -n "$(sudo ls -A "$src")" ]; then
    log "copying $src to $dst"
    sudo rsync -aHAXS --numeric-ids "$src/" "$dst/"
  fi
  sudo chmod --reference="$src" "$dst" 2>/dev/null || true
}
copy_root /var/lib/docker "$DOCKER_ROOT"
copy_root /var/lib/containerd "$CONTAINERD_ROOT"

if command -v semanage >/dev/null 2>&1; then
  log "labelling for SELinux"
  sudo semanage fcontext -l -C | grep -q "^$DOCKER_ROOT = /var/lib/docker" || \
    sudo semanage fcontext -a -e /var/lib/docker "$DOCKER_ROOT"
  sudo semanage fcontext -l -C | grep -q "^$CONTAINERD_ROOT = /var/lib/containerd" || \
    sudo semanage fcontext -a -e /var/lib/containerd "$CONTAINERD_ROOT"
  sudo restorecon -R "$DOCKER_ROOT" "$CONTAINERD_ROOT"
fi

log "pointing dockerd and containerd at $MOUNT"
sudo mkdir -p /etc/docker
if [ -s /etc/docker/daemon.json ]; then
  sudo python3 - "$DOCKER_ROOT" <<'PY'
import json, pathlib, sys
p = pathlib.Path("/etc/docker/daemon.json")
data = json.loads(p.read_text())
data["data-root"] = sys.argv[1]
p.write_text(json.dumps(data, indent=2) + "\n")
PY
else
  printf '{\n  "data-root": "%s"\n}\n' "$DOCKER_ROOT" | sudo tee /etc/docker/daemon.json >/dev/null
fi

if sudo grep -qE '^root\s*=' /etc/containerd/config.toml; then
  sudo sed -i -E "s|^root\s*=.*|root = \"$CONTAINERD_ROOT\"|" /etc/containerd/config.toml
else
  sudo sed -i -E "s|^#root = .*|root = \"$CONTAINERD_ROOT\"|" /etc/containerd/config.toml
  sudo grep -qE '^root\s*=' /etc/containerd/config.toml || \
    printf 'root = "%s"\n' "$CONTAINERD_ROOT" | sudo tee -a /etc/containerd/config.toml >/dev/null
fi

for unit in docker containerd; do
  sudo mkdir -p "/etc/systemd/system/$unit.service.d"
  printf '[Unit]\nRequiresMountsFor=%s\n' "$MOUNT" | \
    sudo tee "/etc/systemd/system/$unit.service.d/data-disk.conf" >/dev/null
done
sudo systemctl daemon-reload

log "starting containerd and docker"
sudo systemctl start containerd.service docker.socket docker.service

root=$(sudo docker info --format '{{.DockerRootDir}}')
[ "$root" = "$DOCKER_ROOT" ] || die "docker still uses $root"
sudo docker images
sudo docker run --rm hello-world >/dev/null || die "hello-world failed on the new storage"

log "removing the old copies under /var/lib"
for old in /var/lib/docker /var/lib/containerd; do
  if [ -d "$old" ] && [ ! -L "$old" ]; then
    sudo rm -rf "$old"
  fi
done

df -h "$MOUNT"
log "docker data now lives on $MOUNT"
