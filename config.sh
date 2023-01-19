#!/bin/bash

# Setting up the submodules
git submodule update --init --recursive

# zsh
ln -sf $PWD/zshrc $HOME/.zshrc
ln -sf $PWD/ohmyzsh $HOME/.oh-my-zsh

# chsh -s /usr/bin/zsh
chmod -R g-w,o-w $PWD/ohmyzsh

# OhMyZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# tmux
mkdir -p $HOME/.config/tmux
ln -sf $PWD/tmux.conf $HOME/.config/tmux/tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# neovim
mkdir -p $HOME/.config/nvim
ln -sf $PWD/init.lua $HOME/.config/nvim/init.lua
ln -sf $PWD/coc-settings.json $HOME/.config/nvim/coc-settings.json

