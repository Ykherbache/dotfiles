#!/usr/bin/env bash
# Sanity check after bootstrap/install.sh. Does not talk to the network.
set -u

fail=0

ok() { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }

need() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "command $1"
  else
    bad "command $1"
  fi
}

need zsh
need git
need stow
need nvim
need tmux
need fzf
need rg
need lsd
need delta
need gh
need git-lfs
need uvx
need aws

if [ "$(uname -s)" = "Linux" ]; then
  distro=
  if [ -r /etc/os-release ]; then
    distro=$(. /etc/os-release && printf '%s' "${ID:-}")
  fi
  if [ "$distro" = "ubuntu" ]; then
    if systemctl is-active --quiet keyd; then
      ok "keyd"
    else
      bad "keyd"
    fi
  elif systemctl is-active --quiet kmonad@mba; then
    ok "kmonad"
  else
    bad "kmonad"
  fi
  if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
    if [ "$(kreadconfig6 --file kwinrc --group Desktops --key Number 2>/dev/null || true)" = "13" ]; then
      ok "kde workspaces"
    else
      bad "kde workspaces"
    fi
  elif [ "$(gsettings get org.gnome.desktop.wm.preferences num-workspaces 2>/dev/null || true)" = "13" ]; then
    ok "gnome workspaces"
  else
    bad "gnome workspaces"
  fi
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    ok "docker daemon"
  else
    bad "docker daemon (group/login or service)"
  fi
  if [ -x "$HOME/.local/bin/epitest" ]; then
    ok "epitest helper"
  else
    bad "epitest helper"
  fi
fi

if [ -L "$HOME/.zshrc" ]; then ok "symlink ~/.zshrc"; else bad "symlink ~/.zshrc"; fi
if [ -L "$HOME/.config/nvim" ]; then ok "symlink ~/.config/nvim"; else bad "symlink ~/.config/nvim"; fi
if [ -L "$HOME/.tmux.conf" ]; then ok "symlink ~/.tmux.conf"; else bad "symlink ~/.tmux.conf"; fi
if [ -L "$HOME/.gitconfig" ]; then ok "symlink ~/.gitconfig"; else bad "symlink ~/.gitconfig"; fi
if [ -x "$HOME/.local/bin/tmux-sessionizer" ]; then ok "tmux-sessionizer"; else bad "tmux-sessionizer"; fi

if zsh -n "$HOME/.zshrc" && zsh -n "$HOME/.config/zsh/plugins.zsh"; then
  ok "zsh syntax"
else
  bad "zsh syntax"
fi

if zsh -ic 'exit' >/tmp/dotfiles-zsh-check.out 2>&1; then
  ok "interactive zsh"
else
  bad "interactive zsh (see /tmp/dotfiles-zsh-check.out)"
fi

if nvim --headless "+checkhealth" +qa >/tmp/dotfiles-nvim-check.out 2>&1; then
  ok "nvim headless"
else
  bad "nvim headless (see /tmp/dotfiles-nvim-check.out)"
fi

if git config --get core.pager | grep -q delta; then
  ok "git pager delta"
else
  bad "git pager delta"
fi

if ssh -G github.com 2>/tmp/dotfiles-ssh-check.out | grep -qi identityfile; then
  ok "ssh config parses"
else
  bad "ssh config parses (see /tmp/dotfiles-ssh-check.out)"
fi

if [ "$fail" -eq 0 ]; then
  echo "base config looks usable"
else
  echo "some checks failed"
fi
exit "$fail"
