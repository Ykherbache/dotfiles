alias vim=nvim
alias vi=nvim
alias c='clear'
alias python=python3
alias vscode='code'
alias dev='yarn start:dev'
alias oracle='ssh ubuntu@129.146.49.54'
alias createkh='tmp_script=$(mktemp) && curl -sSL -o "${tmp_script}" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh && chmod +x "${tmp_script}" && "${tmp_script}" && rm "${tmp_script}"'

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --group-directories-first --almost-all'
fi
