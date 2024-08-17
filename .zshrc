# global env settings
export EDITOR=joe
export DELTA_PAGER='less -FXR'
export LESS='-R'
export LANG='en_US.UTF-8'
export CLICOLOR=1
export CLICOLOR_FORCE=1
export PATH=/opt/local/bin:/opt/local/libexec/gnubin:$PATH
#export PATH=/opt/local/bin:$PATH

export FZF_CTRL_R_OPTS='--sort --ignore-case --no-mouse --border=rounded --scheme=history'
eval "$(fzf --zsh)"

# do not stop terminal on ctrl+s
stty -ixon

# fix ssh forwarding for tmux
if [[ -n "$SSH_TTY" && -S "$SSH_AUTH_SOCK" && ! -h "$SSH_AUTH_SOCK" && ! -e ~/.ssh/ssh_auth_sock ]]; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

# locally, if no agent running, spawn one
if ! socat -u OPEN:/dev/null UNIX-CONNECT:"$SSH_AUTH_SOCK" 2>/dev/null; then
    flock -nx "/tmp/ssh_auth_sock.`id -u`.lock" bash -c "rm -f $SSH_AUTH_SOCK; ssh-agent -a $SSH_AUTH_SOCK >/dev/null"
fi

# support perl via perlbrew
export PERLBREW_ROOT="$HOME/perlbrew"
if [ -d "$PERLBREW_ROOT" ]; then
    source "$PERLBREW_ROOT/etc/bashrc"
    perlbrew use perl-blead
fi

# support node.js via nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if [ ! -d "$HOME/.terminfo" ]; then
    mkdir "$HOME/.terminfo"
    tic -x -o "$HOME/.terminfo" "$HOME/xterm-24bit.terminfo"
fi

if [ -z "$TMUX" ]; then
    export TERM="xterm-24bit"
    export TERM="xterm-256color"
else
    export TERM="xterm-256color"
fi

# no one else knows :(
alias su='TERM=xterm-256color su'
alias sudo='TERM=xterm-256color sudo'
alias ssh='TERM=xterm-256color ssh'

# lxc
alias lxc-ls='lxc-ls -f'
alias lxs-attach='lxs-attach -n'
alias lxs-start='lxs-start -n'
alias lxs-stop='lxs-stop -n'

# jaischeema afowler

# zsh:customize oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.zsh_custom"
export ZSH_THEME="randir"

# zsh:no oh-my-zsh autoupdates
DISABLE_AUTO_UPDATE="true"

# zsh:faster work with repositories
#DISABLE_UNTRACKED_FILES_DIRTY="true"
# zsh:skip git prompt completely
#DISABLE_GIT_PROMPT="true"

if [ ! -d "$ZSH" ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh "$ZSH"
fi

if [ ! -d "$ZSH/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH/plugins/zsh-completions"
fi

# zsh:autocomplete
# do not complain under sudo
ZSH_DISABLE_COMPFIX=true
autoload -U compinit && compinit -Cu

# oh-my-zsh
plugins=(safe-paste zsh-completions)
source $ZSH/oh-my-zsh.sh

# zsh:history
setopt append_history
unsetopt inc_append_history
unsetopt share_history
unsetopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_fcntl_lock
setopt hist_verify

export HISTSIZE=2000000
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zsh_history"

# zsh:silence
setopt nobeep

# zsh:no paste noise
zle_highlight+=(paste:none)

# zsh:search shortcut
#bindkey "^R" history-incremental-pattern-search-backward
bindkey '^r' fzf-history-widget

# alias block
# has to come after oh-my-zsh for the sake of 'll'
alias ll='eza -al'
alias lh='eza -alh'
alias wcl='wc -l'
alias perl-bisect-make='git clean -dxf && ./Configure -de -Dusedevel && make -j5'
alias gti='git' # too common typo
alias vi='vim'
alias g='grep'

function lxc-foreach () {
    local FARGS=$@
    for container in `lxc-ls --running | grep -avF IPV4|awk '{print $1}'`;
        do lxc-attach $container -- /bin/bash -c "$FARGS";
    done
}
