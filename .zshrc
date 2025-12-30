#!/bin/zsh

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

# Start TMUX when launching a new instance of zsh.
if [ -z "$TMUX" ]
then
    tmux attach -t TMUX || tmux new -s TMUX
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Load auxiliary files.
source "$HOME/.zsh_functions"
source "$HOME/.aliases"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

if command -v pyenv > /dev/null; then
      eval "$(pyenv init --path)"
fi

if [[ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]]; then
    eval "$(pyenv virtualenv-init -)"
fi

# Homebrew
if [[ $OSTYPE == 'linux-gnu' ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# ohmyzsh configurations.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="amuse"
plugins=(git pyenv helm kube-ps1)

source $ZSH/oh-my-zsh.sh

# kube-ps1.sh
if [[ $OSTYPE == 'darwin'* ]]; then
  source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
fi

# kubectl
export KUBECONFIG="$HOME/.kube/config"

if [ -d "$HOME/.kube/profiles/" ]; then
    if [ "$(ls -A $HOME/.kube/profiles/)" ]; then
        for FILE in "$HOME"/.kube/profiles/*
        do
            export KUBECONFIG="$KUBECONFIG:$FILE"
        done
    fi
fi

# Editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# Add .local/bin to $PATH.
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:${PATH}"

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

# Load extra configurations on a given machine.
if [ -d "$HOME/.zsh/" ]; then
  for f in $HOME/.zsh/*; do
    source $f
  done
fi

# Gitlab
export GITLAB_TOKEN=$(security find-generic-password -a ${USER} -s gitlab_token -w)

# Add signing key for Github commit signing.
ssh-add -l | grep -q ED25519 || ssh-add --apple-use-keychain ~/.ssh/id_ed25519

PS1='$(kube_ps1)'$PS1
