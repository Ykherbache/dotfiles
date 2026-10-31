# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for three machines: MacBook Air on macOS (`macos-air`), Fedora Asahi on Apple Silicon (`asahi`), and an XPS 15 on Ubuntu (`ubuntu-xps`). There is no build or test suite; the "code" is shell scripts plus config files that GNU Stow links into `$HOME`. `readme.md` is the detailed reference for setup and keyboard behavior.

## Commands

```bash
./bootstrap/install.sh      # idempotent; detects profile, installs packages, stows, runs desktop + keyboard setup
./bootstrap/install-ai.sh   # Claude/opencode tooling
./bootstrap/install-docker.sh
./bootstrap/verify.sh       # sanity check after install (no network)
./bootstrap/gnome.sh        # re-run from a GNOME session (workspaces, Tilix, extensions)
./bootstrap/kde.sh          # re-run from a KDE session (desktops, shortcuts, KWin scripts, panel)
./bootstrap/keyboard.sh     # KMonad (Fedora) or keyd (Ubuntu) setup; needs sudo
stow -t "$HOME" -R <package>   # relink one package after editing it
```

## Architecture

- **Stow packages.** Each top-level directory (`zsh nvim tmux git ssh scripts claude agents opencode mise systemd`) mirrors `$HOME`; the layout inside a package is the target path (e.g. `claude/.claude/settings.json` → `~/.claude/settings.json`). `install.sh` holds the package list in `stow_packages()` — add new packages there. Before stowing, `prepare_stow_targets()` moves conflicting real files to `*.bak-dotfiles`.
- **Not stowed.** `cursor/` is symlinked by `link_cursor()` in `install.sh` because Cursor's settings live outside a Stow-friendly path (macOS vs Linux paths differ; `mcp.json` is special-cased for GitLens). `bootstrap/`, `kde/`, `keyboard/`, `gnome/` are consumed by the bootstrap scripts, not stowed.
- **Profile detection.** `install.sh` `detect_profile()` picks the profile from `uname` and `/etc/os-release`, then installs from `Brewfile`, `fedora-packages.txt` or `ubuntu-packages.txt`. Fedora installs package by package so one missing name doesn't abort the run; macOS uses `brew bundle --no-upgrade` on purpose.
- **Desktop + keyboard layer.** `install.sh` `setup_desktop()` runs `gnome.sh` or `kde.sh` by `XDG_CURRENT_DESKTOP`, then `keyboard.sh`. The keyboard model is shared across machines: hold-tap keys (K = Ctrl, H = switch workspace, J = move window, P = previous workspace) implemented as:
  - Ubuntu: `keyd` via `keyboard/keyd.conf`, with the `gnome-ws` helper.
  - Fedora: KMonad via `keyboard/mba.kbd` (GNOME) or `keyboard/kde.kbd` (KDE). `kmonad@.service` runs the internal keyboard; `kmonad-usb@.service`, `kmonad-usb-sync` and `90-kmonad-usb.rules` start a per-device instance when a USB keyboard is plugged in. `kde-layer-hint` (+ `.service`) draws the "workspace"/"déplacer" label near the pointer.
  - KDE chords sent by `kde.kbd` must match the shortcuts `kde.sh` registers, and `kde/kwin/move-and-follow` is the KWin script they trigger. Change both sides together.
- **Claude config.** `claude/.claude/` is versioned (settings, status line, skills, RTK instructions); credentials, history, plugins, sessions and caches are gitignored. `claude/.claude/skills/` and `agents/.agents/skills/` contain large vendored AWS skill trees — don't hand-edit them. `claude/.claude/skills/synced/` is ignored.
- **Local-only state.** Secrets go in `~/.zshrc.local` (not versioned). `scripts/` (linked to `~/.local/bin`) includes `llm` (Ollama memory helper) and `epitest`.

## Conventions

- Scripts are `bash` with `set -euo pipefail`, log via `log()` (`==> msg`), and must stay idempotent and safe to re-run.
- Per-machine differences belong in the profile branches (`case $PROFILE`), not in separate scripts.
- `readme.md` documents behavior in plain prose; update it when changing setup steps or keyboard gestures.
