#exports
export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0
export ZSH="$HOME/.oh-my-zsh"

#aliases
alias tmux-sessionizer="~/.config/tmux-sessionizer"
alias vim=nvim
alias vi=nvim
ZSH_THEME="simple"

## zsh-autosuggestions ##
# MAC:   brew install zsh-autosuggestions
# Linux: git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
##
## zsh-syntax-highlighting ##
### MAC:   brew install zsh-syntax-highlighting
### Linux: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
##
## zsh-npm-scripts-autocomplete ##
# git clone git@github.com:grigorii-zander/zsh-npm-scripts-autocomplete.git ~/.oh-my-zsh/custom/plugins/zsh-npm-scripts-autocomplete
##
## you-should-use ##
# git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
##
plugins=(git npm gh nvm dirhistory copyfile sudo zsh-autosuggestions zsh-syntax-highlighting zsh-npm-scripts-autocomplete you-should-use)
source $ZSH/oh-my-zsh.sh

export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue,underline
export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue,underline,bold
export YSU_MESSAGE_FORMAT="$(tput bold)$(tput setaf 1)Hey! I found this %alias_type for %command: $(tput setaf 7)%alias$(tput sgr0)"
export YSU_HARDCORE=1
export YSU_MODE=BESTMATCH

#custom bindings
bindkey -s ^f "~/.config/tmux-sessionizer\n"
bindkey -s ^g "~/.config/tmux-attach-session-via-fzf\n"
bindkey -s ^r "~/.config/tmux-attach-pane-via-fzf\n"
bindkey -s ^w "~/.config/create_web_project.sh\nclear\n"
