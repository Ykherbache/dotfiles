# dotfiles

One repo for macOS and Fedora Asahi (GNOME). GNU Stow links each tool into `$HOME`.

```
zsh/ nvim/ tmux/ git/ ssh/ scripts/ claude/ agents/ opencode/ mise/ cursor/
```

`cursor/` is linked by the install script, because Cursor stores its settings outside a single Stow-friendly path. Secrets stay in `~/.zshrc.local`, which is not versioned.

## New machine (Fedora Asahi)

Do this on the Air, with a new SSH key. Do not copy the private key from the Mac.

```bash
ssh-keygen -t ed25519 -C "asahi"
# Add ~/.ssh/id_ed25519.pub to GitHub and GitLab.

mkdir -p ~/personal/github
git clone git@github.com:Yaci016/dotfiles.git ~/personal/github/dotfiles
cd ~/personal/github/dotfiles
./bootstrap/install.sh
./bootstrap/install-ai.sh
```

Create `~/.zshrc.local` with a new GitLab token. Revoke the old one first: it used to live in plaintext in `~/.zshrc`.

```bash
chmod 600 ~/.zshrc.local
# export GITLAB_TOKEN="glpat-..."
```

Then sign in:

- Cursor (the AppImage). If it exits immediately, Asahi's 16K pages are the usual reason: add `--no-sandbox` in `~/.local/bin/cursor`.
- `claude`, then the plugin commands printed by `install-ai.sh`.
- `opencode`
- In Neovim: `:Copilot auth`, then `:Lazy sync`

Check the base setup with `./bootstrap/verify.sh`. In tmux, `prefix + I` installs the plugins.

## This Mac

```bash
./bootstrap/install.sh
./bootstrap/verify.sh
```

`install.sh` moves an existing file to `*.bak-dotfiles` when Stow would otherwise refuse to replace it.

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
