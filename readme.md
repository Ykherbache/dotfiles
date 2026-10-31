# dotfiles

One repo for the MacBook Air on macOS, Fedora Asahi, and the XPS 15 on Ubuntu under Wayland. GNU Stow links each tool into `$HOME`.

`./bootstrap/install.sh` reads the machine and installs one profile:

- `macos-air`: Homebrew, from `bootstrap/Brewfile`. The log prints the `sysctl` model and the `sw_vers` version. Another Mac on macOS gets this same set.
- `asahi`: `dnf`, from `bootstrap/fedora-packages.txt`, on the MacBook Air or the MacBook Pro.
- `ubuntu-xps`: `apt`, from `bootstrap/ubuntu-packages.txt`. When `d2` or `uv` is missing, the script runs that tool's installer (`https://d2lang.com/install.sh`, `https://astral.sh/uv/install.sh`).

```
zsh/ nvim/ tmux/ git/ ssh/ scripts/ claude/ agents/ opencode/ mise/ cursor/
```

`cursor/` is linked by the install script, because Cursor stores its settings outside a single Stow-friendly path. Secrets stay in `~/.zshrc.local`, which is not versioned.

## New machine (Fedora Asahi)

Works on the MacBook Air and on the MacBook Pro M1 Pro. Do this after Fedora Asahi Remix (GNOME) is installed, with a new SSH key. Do not copy the private key from the old machine.

```bash
ssh-keygen -t ed25519 -C "asahi"
# Add ~/.ssh/id_ed25519.pub to GitHub and GitLab.

mkdir -p ~/personal/github
git clone git@github.com:Yaci016/dotfiles.git ~/personal/github/dotfiles
cd ~/personal/github/dotfiles
./bootstrap/install.sh
./bootstrap/install-ai.sh
./bootstrap/install-docker.sh
```

`install.sh` logs `profile asahi`, links the configs and, from a GNOME session, applies the workspaces, Tilix, and KMonad. Log out and back in so the `docker` group and the new keymap both apply.

Copy these yourself; they are not in the repo:

- `~/.aws/` (the `new` profile named by `AWS_PROFILE`)
- a GitLab token in `~/.zshrc.local`, which `install.sh` creates empty. Revoke the old token first: it used to live in plaintext in `~/.zshrc`.

```bash
chmod 600 ~/.zshrc.local
# export GITLAB_TOKEN="glpat-..."
```

`./bootstrap/move-docker-data.sh` is only for a machine that has an ext4 partition labelled `epitech eu`.

Then sign in:

- Cursor (the AppImage). If it exits immediately, Asahi's 16K pages are the usual reason: add `--no-sandbox` in `~/.local/bin/cursor`.
- `claude`, then the plugin commands printed by `install-ai.sh`.
- `opencode`
- In Neovim: `:Copilot auth`, then `:Lazy sync`

Check the base setup with `./bootstrap/verify.sh`. In tmux, `prefix + I` installs the plugins.

### Docker + Epitech dump

Docker CE is configured with `./bootstrap/install-docker.sh` (sudo once). It enables the daemon, adds you to the `docker` group, and pulls the Epitech dump image.

```bash
./bootstrap/install-docker.sh
newgrp docker   # or log out / log in
stow -t "$HOME" -R scripts   # if epitest is not already on PATH
epitest          # shell in the dump, cwd mounted
epitest make re  # any command
```

On Asahi (`aarch64`), the official `epitechcontent/epitest-docker` (amd64) does not run because of 16k pages. The script uses `ximaz/epitest-docker-aarch64` instead. Override with `EPITEST_IMAGE=...`. The chosen image is stored in `~/.config/epitest-image`.

On the Air, Docker and containerd data live on the `epitech eu` ext4 partition, mounted at boot on `/mnt/epitech-eu`. `./bootstrap/move-docker-data.sh` sets this up (fstab, `data-root`, containerd `root`, SELinux labels, `RequiresMountsFor`) and removes the old `/var/lib` copies. Skip it when that partition does not exist.

## Keyboard (GNOME)

On Ubuntu, `keyboard/keyd.conf` does this with keyd, on the internal keyboard and on USB keyboards. Hold **K** for left Ctrl. Hold **H** past 200ms, then a letter, to switch workspace. **P** toggles between the current workspace and the previous one. H sends Shift and Super. Hold **J** past 200ms, then a letter, to move the focused window. J switches like H when the current workspace has no focused window. While H or J is held, a label next to the pointer says `workspace` or `déplacer`. A short tap types the letter.

Fedora Asahi uses the same gestures in KMonad (`keyboard/mba.kbd`). Right Shift stays a normal Shift. Caps Lock is Escape.

| Keys | Workspaces |
| --- | --- |
| A S D F G | 1–5 |
| Z X C V | 6–9 |
| Q W E | 10–12 |
| R | 13 |
| P | précédente |

GNOME only has named shortcuts through workspace 12. R asks the shell for the last workspace. That is workspace 13 only while `num-workspaces` stays 13. The extension tracks the workspace you just left; P switches back to it.

On Fedora, the path checked in to `keyboard/mba.kbd` is the MacBook Air M1. `bootstrap/keyboard.sh` links that file when this machine's keyboard matches, and otherwise writes `/etc/kmonad/mba.kbd` for the internal keyboard: Apple SPI, or `platform-i8042-serio-0-event-kbd` on a PC. External USB keyboards (the main `by-id` interface, not `-ifNN` mice or media keys) get the same keymap in their own instance, for example `kmonad@nuphy-air75-v2`. Plugging one in starts that instance. Unplugging stops it and leaves the file in `/etc/kmonad`. The instance is not enabled at boot, so a missing cable does not restart KMonad in a loop. `bootstrap/keyboard.sh` installs the udev rule and the oneshot that do this, including for a keyboard that is already plugged in. `sudo systemctl restart kmonad@mba` reloads the internal keymap.

Workspaces, Caps Lock as Escape, the Tilix profile, and the Shell extensions come from `bootstrap/gnome.sh`. `install.sh` runs it when `XDG_CURRENT_DESKTOP` contains `GNOME`. Run it again from a GNOME session if an extension no longer matches the Shell version.

## Keyboard (KDE Plasma)

On a KDE session, `install.sh` runs `bootstrap/kde.sh` instead of `gnome.sh`. It sets 13 virtual desktops in one row, binds Hyper plus a letter to "Switch to Desktop N" and Shift+Alt+Super plus a letter to the `kde/kwin/move-and-follow` KWin script, which moves the window and switches there with it as GNOME does, maps Caps Lock to Escape, and loads the Tilix profile. KMonad then uses `keyboard/kde.kbd`: hold **H** for Ctrl+Alt+Shift+Super, and hold **J** for Alt+Shift+Super. Those are the chords the Plasma shortcuts already listen for. While H or J is held, a label next to the pointer says `workspace` or `déplacer`. `gnome-ws` is only the GNOME path. KDE has a real desktop 13, so R goes there directly. It also turns animations off (instant speed, no slide or popup on a desktop switch) and disables the Baloo and localsearch file indexers. In place of the GNOME extensions, `kde/plasma/panel.js` makes the panel Pager show app icons instead of desktop numbers, and adds a text-only RAM percentage. Log out and back in if a shortcut or Caps Lock does not apply right away.

On Ubuntu, `bootstrap/keyboard.sh` installs the `keyd` package, copies `keyboard/keyd.conf` to `/etc/keyd/default.conf`, stops any `kmonad@` instance, and adds you to the `keyd` group. Log out once so the pointer label can read keyd. On aarch64 Fedora, install `kmonad` with `dnf` first.

```bash
./bootstrap/keyboard.sh
```

## Ubuntu (XPS 15)

```bash
./bootstrap/install.sh
./bootstrap/install-ai.sh
./bootstrap/verify.sh
```

On this XPS 15, `install.sh` logs `profile ubuntu-xps` with the DMI product and `XDG_SESSION_TYPE`. It installs `bootstrap/ubuntu-packages.txt` and links `fdfind` to `~/.local/bin/fd`. When `d2` or `uv` is absent, that tool's installer runs. From a GNOME session the script applies the workspaces, Tilix, keyd, and the pointer label. Packages install from a GNOME session or from SSH. Log out once so the `keyd` group applies. `./bootstrap/verify.sh` checks that `keyd` is active.

## This Mac

Profile `macos-air`. `install.sh` logs the model and the macOS version, then installs `bootstrap/Brewfile`.

```bash
./bootstrap/install.sh
./bootstrap/verify.sh
```

`install.sh` moves an existing file to `*.bak-dotfiles` when Stow would otherwise refuse to replace it.

## Local LLM memory

`llm` (in `scripts/`, linked to `~/.local/bin`) frees the RAM that Ollama keeps for a loaded model. A 30B model holds
about 21 GB until its keep-alive runs out, which is most of a 31 GB machine. It needs only the `ollama` CLI, so it works
the same on Fedora Asahi and macOS.

```bash
llm ps                  # loaded models, RAM available, swap, SearXNG
llm free                # unload every model now (llmfree)
llm free <model>        # unload one
llm free --all          # also stop the SearXNG container
llm warm <model>        # load a model now, so the 10-40 s cold start happens when you pick (llmwarm)
```

If a model stays loaded after 15 s, `llm free` prints the last resort (`sudo systemctl restart ollama` on Linux,
`brew services restart ollama` on macOS). `LLM_KEEP_ALIVE` (default `30m`) sets the keep-alive used by `llm warm`.

## Layout

| Package | Lands in |
| --- | --- |
| zsh | `~/.zshrc`, `~/.config/zsh/` |
| nvim | `~/.config/nvim` |
| tmux | `~/.tmux.conf` |
| git | `~/.gitconfig`, `~/.config/git/ignore` |
| ssh | `~/.ssh/config` (never the keys) |
| scripts | `~/.local/bin` |
| claude | `~/.claude` settings, status line, skills |
| agents | `~/.agents/skills` |
| opencode | `~/.config/opencode` |
| mise | `~/.config/mise/config.toml` |
