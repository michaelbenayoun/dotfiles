# dotfiles

Personal config files for macOS dev environment.

## What's included

| Tool | File(s) |
|------|---------|
| Zsh + Oh My Zsh | `zshrc`, `ohmyzsh/` |
| tmux | `tmux.conf` |
| Neovim | `init.lua`, `lazy.lua`, `plugins.lua`, `avante.lua` |
| Ghostty | `ghostty_config` |
| Git | `gitconfig` |

## Setup

Clone the repo, then run the setup script:

```sh
git clone <repo>
cd dotfiles
./config.sh
```

`config.sh` creates symlinks from each config file to its expected location under `~/.config/` or `$HOME`.

> After running, install the Ghostty theme manually (see terminal output for the reminder).

## File reference

```
zshrc           → ~/.zshrc
ohmyzsh/        → ~/.oh-my-zsh (submodule)
tmux.conf       → ~/.config/tmux/tmux.conf
init.lua        → ~/.config/nvim/init.lua
lazy.lua        → ~/.config/nvim/lua/config/lazy.lua
plugins.lua     → ~/.config/nvim/lua/plugins.lua
avante.lua      → ~/.config/nvim/lua/config/avante.lua
ghostty_config  → ~/.config/ghostty/config
gitconfig       → ~/.gitconfig
```
