#!/usr/bin/env bash
# Idempotent setup. Picks macos-air, asahi, or ubuntu-xps from the machine.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

OS=$(uname -s)
PROFILE=

if [ "$OS" = "Darwin" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

log() { printf '==> %s\n' "$*"; }

detect_profile() {
  case $OS in
    Darwin)
      local model version
      model=$(sysctl -n hw.model 2>/dev/null || true)
      version=$(sw_vers -productVersion 2>/dev/null || true)
      PROFILE=macos-air
      log "profile $PROFILE (macOS ${version:-unknown}, ${model:-unknown model})"
      ;;
    Linux)
      local id product session
      id=unknown
      if [ -r /etc/os-release ]; then
        id=$(. /etc/os-release && printf '%s' "${ID:-unknown}")
      fi
      case $id in
        fedora|fedora-asahi-remix)
          PROFILE=asahi
          product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
          if [ -z "$product" ] && [ -r /proc/device-tree/model ]; then
            product=$(tr -d '\0' </proc/device-tree/model)
          fi
          log "profile $PROFILE (${product:-unknown model})"
          ;;
        ubuntu)
          PROFILE=ubuntu-xps
          product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
          session=${XDG_SESSION_TYPE:-none}
          log "profile $PROFILE (${product:-unknown model}, session $session)"
          ;;
        *)
          echo "This Linux is not Fedora or Ubuntu (got ID=$id)." >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported OS: $OS" >&2
      exit 1
      ;;
  esac
}

detect_profile

backup_path() {
  local target=$1
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi
  if [ -L "$target" ]; then
    local resolved
    resolved=$(realpath "$target" 2>/dev/null || true)
    # Leave a symlink alone only when it already points at a live file in this repo.
    if [ -n "$resolved" ] && [[ "$resolved" == "$ROOT/"* ]]; then
      return 0
    fi
  fi
  mv "$target" "${target}.bak-dotfiles"
  log "backed up $target"
}

link_fd() {
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_curl_sh() {
  local cmd=$1 url=$2
  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi
  log "installing $cmd"
  curl -fsSL "$url" | sh
  export PATH="$HOME/.local/bin:$PATH"
}

install_packages() {
  local pkg
  case $PROFILE in
    asahi)
      log "installing Fedora packages"
      # One missing name used to abort the whole transaction, so Stow never ran.
      local missing=()
      while IFS= read -r pkg || [ -n "$pkg" ]; do
        case $pkg in
          ''|'#'*) continue ;;
        esac
        if ! sudo dnf install -y "$pkg"; then
          missing+=("$pkg")
          log "skipped $pkg (not in the Fedora repos for this arch)"
        fi
      done < "$ROOT/bootstrap/fedora-packages.txt"
      if [ "${#missing[@]}" -gt 0 ]; then
        log "still missing: ${missing[*]}"
      fi
      link_fd
      ;;
    ubuntu-xps)
      log "installing Ubuntu packages"
      local pkgs=()
      while IFS= read -r pkg || [ -n "$pkg" ]; do
        case $pkg in
          ''|'#'*) continue ;;
        esac
        pkgs+=("$pkg")
      done < "$ROOT/bootstrap/ubuntu-packages.txt"
      sudo DEBIAN_FRONTEND=noninteractive apt-get update
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
      link_fd
      install_curl_sh d2 https://d2lang.com/install.sh
      install_curl_sh uv https://astral.sh/uv/install.sh
      ;;
    macos-air)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required on macOS: https://brew.sh" >&2
        exit 1
      fi
      log "installing Homebrew packages"
      # Do not upgrade already-installed formulae. A delta/rtk upgrade can rebuild LLVM.
      brew bundle --no-upgrade --file="$ROOT/bootstrap/Brewfile"
      ;;
    *)
      echo "Unsupported profile: ${PROFILE:-unset}" >&2
      exit 1
      ;;
  esac
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "installing oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

clone_plugin() {
  local name=$1 url=$2
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  if [ ! -d "$dest/.git" ]; then
    log "cloning $name"
    git clone --depth 1 "$url" "$dest"
  fi
}

install_zsh_plugins() {
  clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
  clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
  clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab
  clone_plugin zsh-fzf-history-search https://github.com/joshskidmore/zsh-fzf-history-search
  clone_plugin zsh-npm-scripts-autocomplete https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete
  clone_plugin you-should-use https://github.com/MichaelAquilina/zsh-you-should-use
  clone_plugin zsh-peco-history https://github.com/jimeh/zsh-peco-history
}

install_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    log "installing mise"
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
  if [ -f "$HOME/.config/mise/config.toml" ] || [ -f "$ROOT/mise/.config/mise/config.toml" ]; then
    log "installing node, go, bun, and pnpm with mise"
    MISE_YES=1 mise install || log "mise install failed; run 'mise install' again"
  fi
}

install_tpm() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    log "installing tmux plugin manager"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
}

install_font() {
  local name=$1
  local dir=$HOME/.local/share/fonts
  if fc-list 2>/dev/null | grep -qi "$name Nerd Font"; then
    return 0
  fi
  mkdir -p "$dir"
  local tmp
  tmp=$(mktemp -d)
  log "downloading $name Nerd Font"
  curl -fsSL -o "$tmp/font.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.tar.xz"
  tar -xJf "$tmp/font.tar.xz" -C "$dir"
  rm -rf "$tmp"
}

install_fonts() {
  if [ "$OS" = "Darwin" ]; then
    return 0
  fi
  install_font JetBrainsMono
  install_font FiraCode
  fc-cache -f >/dev/null 2>&1 || true
}

remove_old_script_links() {
  local name
  for name in cht.sh tmux-cht.sh tmux-sessionizer tmux-attach-pane-via-fzf tmux-attach-session-via-fzf create_web_project.sh; do
    if [ -L "$HOME/.config/$name" ]; then
      rm "$HOME/.config/$name"
    fi
  done
}

prepare_stow_targets() {
  mkdir -p "$HOME/.ssh/config.d" "$HOME/.config" "$HOME/.local/bin"
  remove_old_script_links
  backup_path "$HOME/.zshrc"
  backup_path "$HOME/.tmux.conf"
  backup_path "$HOME/.gitconfig"
  backup_path "$HOME/.config/git/ignore"
  backup_path "$HOME/.ssh/config"
  backup_path "$HOME/.config/nvim"
  backup_path "$HOME/.config/mise/config.toml"
  backup_path "$HOME/.config/opencode/opencode.json"
  backup_path "$HOME/.claude/settings.json"
  backup_path "$HOME/.claude/CLAUDE.md"
  backup_path "$HOME/.claude/RTK.md"
  backup_path "$HOME/.claude/statusline-command.sh"

  local skill
  shopt -s nullglob
  for skill in "$ROOT/claude/.claude/skills"/* "$ROOT/agents/.agents/skills"/*; do
    local base
    base=$(basename "$skill")
    case $skill in
      "$ROOT/claude/"*) backup_path "$HOME/.claude/skills/$base" ;;
      "$ROOT/agents/"*) backup_path "$HOME/.agents/skills/$base" ;;
    esac
  done
  shopt -u nullglob

  if [ -f "${HOME}/.zshrc.bak-dotfiles" ]; then
    # The old shell file held a GitLab token in plaintext. Keep the backup, drop the secret.
    if [ "$(uname -s)" = "Darwin" ]; then
      sed -i '' '/GITLAB_TOKEN/d' "${HOME}/.zshrc.bak-dotfiles"
    else
      sed -i '/GITLAB_TOKEN/d' "${HOME}/.zshrc.bak-dotfiles"
    fi
  fi
}

stow_packages() {
  local package
  for package in zsh nvim tmux git ssh scripts claude agents opencode mise; do
    log "stowing $package"
    stow -t "$HOME" -R "$package"
  done
  if [ "$OS" != "Darwin" ]; then
    log "stowing systemd"
    stow -t "$HOME" -R systemd
    systemctl --user daemon-reload
    systemctl --user enable rtk-proxy.service
  fi
}

link_cursor() {
  local cursor_user keybindings
  mkdir -p "$HOME/.cursor/skills" "$HOME/.ssh/config.d"
  if [ "$OS" = "Darwin" ]; then
    cursor_user="$HOME/Library/Application Support/Cursor/User"
    keybindings=keybindings.json
  else
    cursor_user="$HOME/.config/Cursor/User"
    keybindings=keybindings.linux.json
  fi
  mkdir -p "$cursor_user"
  backup_path "$cursor_user/settings.json"
  backup_path "$cursor_user/keybindings.json"
  backup_path "$HOME/.cursor/mcp.json"
  ln -sfn "$ROOT/cursor/settings.json" "$cursor_user/settings.json"
  ln -sfn "$ROOT/cursor/$keybindings" "$cursor_user/keybindings.json"

  if [ "$OS" = "Darwin" ]; then
    local gk="$cursor_user/globalStorage/eamodio.gitlens/gk"
    if [ -x "$gk" ]; then
      python3 - "$ROOT/cursor/mcp.json" "$HOME/.cursor/mcp.json" "$gk" <<'PY'
import json, pathlib, sys
base, dest, gk = sys.argv[1:]
data = json.loads(pathlib.Path(base).read_text())
data.setdefault("mcpServers", {})["GitKraken"] = {
    "command": gk,
    "type": "stdio",
    "name": "GitKraken",
    "args": ["mcp", "--host=cursor", "--source=gitlens", "--scheme=cursor"],
    "env": {},
}
pathlib.Path(dest).write_text(json.dumps(data, indent=2) + "\n")
PY
    else
      ln -sfn "$ROOT/cursor/mcp.json" "$HOME/.cursor/mcp.json"
    fi
  else
    ln -sfn "$ROOT/cursor/mcp.json" "$HOME/.cursor/mcp.json"
  fi

  local skill base
  shopt -s nullglob
  for skill in "$HOME/.agents/skills"/*; do
    [ -d "$skill" ] || continue
    base=$(basename "$skill")
    backup_path "$HOME/.cursor/skills/$base"
    ln -sfn "$skill" "$HOME/.cursor/skills/$base"
  done
  shopt -u nullglob

  if command -v cursor >/dev/null 2>&1; then
    log "installing Cursor extensions"
    while IFS= read -r ext; do
      [ -z "$ext" ] && continue
      cursor --install-extension "$ext" || log "could not install $ext"
    done < "$ROOT/cursor/extensions.txt"
  fi
}

link_orbstack_ssh() {
  if [ -f "$HOME/.orbstack/ssh/config" ]; then
    mkdir -p "$HOME/.ssh/config.d"
    printf 'Include ~/.orbstack/ssh/config\n' > "$HOME/.ssh/config.d/orbstack.conf"
  fi
}

setup_desktop() {
  if [ "$OS" != "Linux" ]; then
    return 0
  fi
  if command -v gsettings >/dev/null 2>&1 && [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]]; then
    "$ROOT/bootstrap/gnome.sh"
  elif command -v kwriteconfig6 >/dev/null 2>&1 && [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
    "$ROOT/bootstrap/kde.sh"
  else
    log "no GNOME or KDE session; run bootstrap/gnome.sh or bootstrap/kde.sh from one"
  fi
  "$ROOT/bootstrap/keyboard.sh"
}

ensure_login_shell() {
  local zsh_path
  zsh_path=$(command -v zsh)
  if [ "$(basename "$SHELL")" = "zsh" ]; then
    return 0
  fi
  log "switching login shell to zsh"
  chsh -s "$zsh_path" || sudo chsh -s "$zsh_path" "$USER" || \
    echo "Could not change the login shell. Run: chsh -s $zsh_path"
}

install_packages
if command -v git-lfs >/dev/null 2>&1; then
  git lfs install --skip-repo || log "git lfs install failed; run it again after git-lfs is installed"
fi
install_oh_my_zsh
install_zsh_plugins
install_tpm
install_fonts
prepare_stow_targets
stow_packages
install_mise
link_cursor
link_orbstack_ssh
setup_desktop
ensure_login_shell

if [ ! -f "$HOME/.zshrc.local" ]; then
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-local shell. This file is not in the dotfiles repo.
# Put a new GitLab token here after revoking the old one:
#   https://gitlab.com/-/user_settings/personal_access_tokens
# export GITLAB_TOKEN="glpat-..."
EOF
  chmod 600 "$HOME/.zshrc.local"
fi

log "shell, editor, and git configs are linked"
echo "Next, on a new machine: ./bootstrap/install-ai.sh"
echo "Then check: ./bootstrap/verify.sh"
