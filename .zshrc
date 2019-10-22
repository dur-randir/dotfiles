# global env settings
export TERM="xterm-256color"
export EDITOR=joe
export LESS='-R'
export LANG='en_US.UTF-8'
export CLICOLOR=1
export CLICOLOR_FORCE=1
export PATH=/opt/local/bin:/usr/texbin:$PATH

# alias block
alias ll='ls -al'
alias lh='ls -alh'
alias g='egrep -d skip -In --'
alias gv='egrep -d skip -Iv --'
alias wcl='wc -l'
alias perl-bisect-make='git clean -dxf && ./Configure -de -Dusedevel && make -j5'
alias gti='git' # too common typo
alias vi='vim'

alias lxc-ls='lxc-ls -f'
alias lxs-attach='lxs-attach -n'
alias lxs-start='lxs-start -n'
alias lxs-stop='lxs-stop -n'

# do not stop terminal on ctrl+s
stty -ixon

# fix ssh forwarding for tmux
if [[ -n "$SSH_TTY" && -S "$SSH_AUTH_SOCK" && ! -h "$SSH_AUTH_SOCK" ]]; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock

# support perl via perlbrew
export PERLBREW_ROOT="$HOME/perlbrew"
if [ -d "$PERLBREW_ROOT" ]; then
    source "$PERLBREW_ROOT/etc/bashrc"
    perlbrew use perl-blead
fi

# support node.js via nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# jaischeema afowler

# zsh:customize oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.zsh_custom"
export ZSH_THEME="randir"

# zsh:no oh-my-zsh. autoupdates
DISABLE_AUTO_UPDATE="true"

# zsh:faster work with repositories
#DISABLE_UNTRACKED_FILES_DIRTY="true"

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
setopt extended_history
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

# zsh:vi mode
# bindkey -v # messes up with ctrl-a

# zsh:search shortcut
bindkey "^R" history-incremental-pattern-search-backward
