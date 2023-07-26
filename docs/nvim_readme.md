### quick readme for stuff required to setup nvim well on new workstation

- after creating a symlink from inside configs/nvim to ~/.config/nvim with this command:
  - "ln -s $(pwd) ~/.config/nvim"
- on first launch after install, you will see lot of errors, edit the packer.lua file with nvim, source it and install plugins with :PackerInstall
- there are some packages that will require you to git clone them so they be effective
  - packer with
    - git clone --depth 1 https://github.com/wbthomason/packer.nvim\ ~/.local/share/nvim/site/pack/packer/start/packer.nvim
