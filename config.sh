#!/bin/bash

echo "Setting up submodules..."
git submodule update --init --recursive

echo "Setting up zsh..."
ln -sf $PWD/zshrc $HOME/.zshrc
ln -sf $PWD/ohmyzsh $HOME/.oh-my-zsh
chmod -R g-w,o-w $PWD/ohmyzsh

echo "Setting up Oh My Zsh plugins..."
[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Setting up tmux..."
mkdir -p $HOME/.config/tmux
ln -sf $PWD/tmux.conf $HOME/.config/tmux/tmux.conf
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Setting up neovim..."
mkdir -p $HOME/.config/nvim/lua/config
ln -sf $PWD/init.lua $HOME/.config/nvim/init.lua
ln -sf $PWD/lazy.lua $HOME/.config/nvim/lua/config/lazy.lua
ln -sf $PWD/plugins.lua $HOME/.config/nvim/lua/plugins.lua
ln -sf $PWD/avante.lua $HOME/.config/nvim/lua/config/avante.lua

echo "Setting up ghostty..."
mkdir -p $HOME/.config/ghostty
ln -sf $PWD/ghostty_config $HOME/.config/ghostty/config
echo "  -> Please install the Ghostty theme manually."

echo "Setting up git..."
ln -sf $PWD/gitconfig $HOME/.gitconfig

echo "Done."
