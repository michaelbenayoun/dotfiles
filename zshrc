# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
# ZSH_THEME="cappuccin"

# Homebrew paths
if [ -d /opt/homebrew/bin ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi
if [ -d /opt/homebrew/sbin ]; then
  export PATH=/opt/homebrew/sbin:$PATH
fi

export ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf
plugins=(
  git
  vi-mode
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
  python
  pip
  command-not-found
  tmux
)
source $ZSH/oh-my-zsh.sh

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=147'  # soft lavender
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796 \
--color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6 \
--color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796 \
--color=selected-bg:#494D64 \
--color=border:#6E738D,label:#CAD3F5"

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias vim="nvim"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To use Homebrew's ruby instead of Mac system ruby.
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

if [ -f "$HOME/.local/bin/env" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Source fzf key bindings and completions
for fzf_file in key-bindings.zsh completion.zsh; do
    for fzf_path in \
        ~/.fzf/$fzf_file \
        /usr/share/fzf/$fzf_file \
        /usr/share/doc/fzf/examples/$fzf_file \
        $(brew --prefix 2>/dev/null)/opt/fzf/shell/$fzf_file
    do
        [ -f "$fzf_path" ] && source "$fzf_path" && break
    done
done

# Add to remote ~/.zshrc
if ! infocmp "$TERM" &>/dev/null; then
    export TERM=xterm-256color
fi
