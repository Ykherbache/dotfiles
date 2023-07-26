### quick readme for stuff required to setup tmux well on new workstation

- use this to setup tmux plugun manager in new workstation
  -git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  -edit/create ~.tmux.conf
  ```
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      run '~/.tmux/plugins/tpm/tpm'
  ```
