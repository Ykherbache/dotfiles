# Shared shell. Secrets stay in ~/.zshrc.local, which is not versioned.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# OS paths (Homebrew, pnpm) must exist before plugin and tool detection.
case "$OSTYPE" in
  darwin*) source "$HOME/.config/zsh/macos.zsh" ;;
  linux*) source "$HOME/.config/zsh/linux.zsh" ;;
esac

source "$HOME/.config/zsh/plugins.zsh"
source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/tools.zsh"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
