export PATH="$HOME/.local/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v ng >/dev/null 2>&1 && source <(ng completion script)
command -v go >/dev/null 2>&1 && export PATH="$PATH:$(go env GOPATH)/bin"

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd 'v' edit-command-line
