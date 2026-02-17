#!/bin/bash

# Setting up the submodules
git submodule update --init --recursive

# zsh
ln -sf $PWD/zshrc $HOME/.zshrc
ln -sf $PWD/ohmyzsh $HOME/.oh-my-zsh

# chsh -s /usr/bin/zsh
chmod -R g-w,o-w $PWD/ohmyzsh

# OhMyZSH plugins
[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# tmux
mkdir -p $HOME/.config/tmux
ln -sf $PWD/tmux.conf $HOME/.config/tmux/tmux.conf
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# neovim
mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.config/nvim/lua/config

ln -sf $PWD/init.lua $HOME/.config/nvim/init.lua
ln -sf $PWD/lazy.lua $HOME/.config/nvim/lua/config/lazy.lua
ln -sf $PWD/plugins.lua $HOME/.config/nvim/lua/plugins.lua
ln -sf $PWD/avante.lua $HOME/.config/nvim/lua/config/avante.lua

# ghostty
mkdir -p $HOME/.config/ghostty
ln -sf $PWD/ghostty_config $HOME/.config/ghostty/config
echo "Ghostty config linked, please install the theme manually."

# git
ln -sf $PWD/gitconfig $HOME/.gitconfig
