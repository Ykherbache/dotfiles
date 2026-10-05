if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

[ -f "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"
[ -f "$HOME/.orbstack/shell/init.zsh" ] && source "$HOME/.orbstack/shell/init.zsh"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/.dotnet/tools"

if [ -d /opt/homebrew/opt/dotnet@8 ]; then
  export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
  export DOTNET_ROOT="/opt/homebrew/opt/dotnet@8/libexec"
fi
[ -d /opt/homebrew/opt/mysql-client ] && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if [ -d /Applications/Pen.app ]; then
  export OPENCODE_CONFIG="$HOME/.config/opencode/opencode.macos.json"
fi
