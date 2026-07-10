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

# Homebrew
if [[ $OSTYPE == 'linux-gnu' ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# ohmyzsh configurations.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="amuse"
plugins=(git pyenv helm kube-ps1 bazel)

source $ZSH/oh-my-zsh.sh

# zsh-autosuggestions plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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

# Add signing key for Github commit signing.
ssh-add -l | grep -q ED25519 || ssh-add --apple-use-keychain ~/.ssh/id_ed25519

PS1='$(kube_ps1)'$PS1

export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

# BEGIN SCFW MANAGED BLOCK
alias npm="scfw run npm"
alias pip="scfw run pip"
alias poetry="scfw run poetry"
export SCFW_DD_AGENT_LOG_PORT="10365"
export SCFW_DD_LOG_LEVEL="ALLOW"
export SCFW_HOME="/Users/hugo.martins/.scfw"
# END SCFW MANAGED BLOCK
