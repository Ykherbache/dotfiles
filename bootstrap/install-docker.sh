#!/usr/bin/env bash
# Install and configure Docker + Epitech epitest image on Fedora (Asahi OK).
# Idempotent. Needs sudo once (password).
set -euo pipefail

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "run as your user, not root (script uses sudo)"
command -v sudo >/dev/null 2>&1 || die "sudo is required"

ARCH=$(uname -m)
OS=$(uname -s)
[ "$OS" = "Linux" ] || die "Linux only (got $OS)"

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  die "cannot read /etc/os-release"
fi

case ${ID:-} in
  fedora|fedora-asahi-remix) ;;
  *) die "Fedora expected (got ID=${ID:-unknown})" ;;
esac

log "installing Docker Engine (docker-ce) from Docker's Fedora repo"
sudo dnf -y install dnf-plugins-core
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
fi

# Drop Fedora's moby packages if present; they conflict with docker-ce.
sudo dnf -y remove docker docker-client docker-client-latest docker-common \
  docker-latest docker-latest-logrotate docker-logrotate docker-selinux \
  docker-engine-selinux docker-engine moby-engine 2>/dev/null || true

sudo dnf -y install \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# iptables-nft is required on recent Fedora when docker fails with "failed to find iptables"
if command -v alternatives >/dev/null 2>&1 && [ -x /usr/bin/iptables-nft ]; then
  sudo alternatives --set iptables /usr/bin/iptables-nft 2>/dev/null || true
fi

log "enabling docker service"
sudo systemctl enable --now docker

log "adding $USER to the docker group"
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

# Official epitest is linux/amd64 only. On aarch64, install qemu user emulation
# so `docker pull/run --platform linux/amd64` can work (slow, may fail on 16k pages).
if [ "$ARCH" = "aarch64" ]; then
  log "aarch64 host: installing qemu-user-static for amd64 epitest image"
  sudo dnf -y install qemu-user-static qemu-user-binfmt || \
    log "could not install qemu-user-static; try community image ximaz/epitest-docker-aarch64"
fi

log "smoke test (hello-world)"
sudo docker run --rm hello-world

# Official epitest is linux/amd64 only. On Asahi (aarch64 + 16k pages), qemu
# usually cannot exec it ("no such file or directory"). Prefer the community
# arm64 image unless EPITEST_IMAGE is set explicitly.
if [ -z "${EPITEST_IMAGE:-}" ]; then
  if [ "$ARCH" = "aarch64" ]; then
    EPITEST_IMAGE=ximaz/epitest-docker-aarch64:latest
  else
    EPITEST_IMAGE=epitechcontent/epitest-docker:latest
  fi
fi

log "pulling Epitech image: $EPITEST_IMAGE"
if [ "$ARCH" = "aarch64" ] && [[ "$EPITEST_IMAGE" == *epitechcontent/epitest-docker* ]]; then
  sudo docker pull --platform linux/amd64 "$EPITEST_IMAGE" || true
  if ! sudo docker run --rm --platform linux/amd64 "$EPITEST_IMAGE" true 2>/dev/null; then
    log "official amd64 image cannot run here; switching to ximaz/epitest-docker-aarch64"
    EPITEST_IMAGE=ximaz/epitest-docker-aarch64:latest
    sudo docker pull "$EPITEST_IMAGE"
  fi
else
  sudo docker pull "$EPITEST_IMAGE"
fi

# Persist which image the helper should use
mkdir -p "$HOME/.config"
printf '%s\n' "$EPITEST_IMAGE" > "$HOME/.config/epitest-image"
chmod 644 "$HOME/.config/epitest-image"

cat <<EOF

Docker is ready.

Packages: docker-ce, compose plugin, buildx
Service:  enabled + running
Group:    $USER added to docker (re-login or: newgrp docker)
Image:    $EPITEST_IMAGE  (saved in ~/.config/epitest-image)

Next:
  newgrp docker   # or log out / log in
  docker run --rm hello-world
  epitest         # interactive shell in the dump (after stow scripts)
  epitest make    # run a command in the current directory

EOF
