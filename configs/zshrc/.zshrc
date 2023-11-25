#exports
export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0
export ZSH="$HOME/.oh-my-zsh"

#aliases
alias tmux-sessionizer="~/.config/tmux-sessionizer"
alias vim=nvim
alias vi=nvim
ZSH_THEME="simple"
plugins=(git npm gh nvm dirhistory copyfile sudo zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

#custom bindings
bindkey -s ^f "~/.config/tmux-sessionizer\n"
bindkey -s ^g "~/.config/tmux-attach-session-via-fzf\n"
bindkey -s ^r "~/.config/tmux-attach-pane-via-fzf\n"
