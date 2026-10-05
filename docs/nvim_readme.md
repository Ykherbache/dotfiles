Neovim is the `nvim` Stow package (`~/.config/nvim`). `bootstrap/install.sh` links it.

On first launch, Lazy installs plugins. For Copilot, run `:Copilot auth` once. `:Lazy sync`, `:checkhealth`, and `:Mason` are the health checks. On ARM64 Linux, some Mason binaries are missing; install that language server with dnf or npm instead.
