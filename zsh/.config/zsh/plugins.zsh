ZSH_THEME="simple"

export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export YSU_MESSAGE_FORMAT="$(tput bold)$(tput setaf 1)Hey! I found this %alias_type for %command: $(tput setaf 7)%alias$(tput sgr0)"
export YSU_HARDCORE=1
export YSU_MODE=BESTMATCH
export ZSH_FZF_HISTORY_SEARCH_BIND='^n'

plugins=(
  git npm gh dirhistory copyfile sudo golang
  zsh-autosuggestions zsh-syntax-highlighting
  zsh-npm-scripts-autocomplete you-should-use
  fzf-tab zsh-fzf-history-search zsh-peco-history
)
[ -s "$HOME/.nvm/nvm.sh" ] && plugins+=(nvm)
command -v kubectl >/dev/null 2>&1 && plugins+=(kubectl)
command -v dotnet >/dev/null 2>&1 && plugins+=(dotnet)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "oh-my-zsh is missing. Run bootstrap/install.sh" >&2
fi

if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
  export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue,underline
  export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
  export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue,underline,bold
fi

bindkey '  ' autosuggest-accept

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always --icon=never $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'lsd --color=always --icon=never $realpath 2>/dev/null || ls -la $realpath'

bindkey -s '^w' "create_web_project.sh\nclear\n"
bindkey -s '^o' "~/personal/html-css-tests\nclear\n"
bindkey -s '^p' "~/personal/gitlab/onepiece-rpg/op-rpg\nclear\n"

NEWLINE=$'\n┗>'
PROMPT="$PROMPT $NEWLINE "
