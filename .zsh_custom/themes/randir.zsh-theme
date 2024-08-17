zmodload zsh/pcre

git_status() {
  local INDEX git_status
  local -a FLAGS

  FLAGS=('--porcelain' '--ignore-submodules=dirty' '-b')
  if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
    FLAGS+='--untracked-files=no'
  fi

  INDEX=$(command git status ${FLAGS} 2> /dev/null)

  pcre_compile -m '^[?][?] '
  pcre_match $INDEX && git_status="$ZSH_GIT_STATUS_UNTRACKED$git_status"

  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    git_status="$ZSH_GIT_STATUS_STASHED$git_status"
  fi

  local NEED_GIT_STATUS_MODIFIED
  pcre_compile -m '^[ MARC]M '
  pcre_match $INDEX && NEED_GIT_STATUS_MODIFIED=1
  if [[ -z "$NEED_GIT_STATUS_MODIFIED" ]]; then
    pcre_compile -m '^[MARC]  '
    pcre_match $INDEX && NEED_GIT_STATUS_MODIFIED=1
  fi
  [[ ! -z $NEED_GIT_STATUS_MODIFIED ]] && git_status="$ZSH_GIT_STATUS_MODIFIED$git_status"

  local -a ARR
  local c_ahead c_behind git_up_status

  pcre_compile '^##.*ahead (\d+)'
  pcre_match -a ARR $INDEX && c_ahead="$ARR[1]"

  pcre_compile '^##.*behind (\d+)'
  pcre_match -a ARR $INDEX && c_behind="$ARR[1]"

  if [[ 0 == 1 && $c_ahead -gt 0 && $c_behind -gt 0 ]]; then
    git_up_status="$ZSH_GIT_STATUS_DIVERGED"
  else
    [[ $c_ahead -gt 0 ]] && git_up_status="$git_up_status$ZSH_GIT_STATUS_AHEAD$c_ahead"
    [[ $c_behind -gt 0 ]] && git_up_status="$git_up_status$ZSH_GIT_STATUS_BEHIND$c_behind"
  fi

  if [[ -n "$git_up_status" || -n "$git_status" ]]; then
    [[ -n "$git_status" ]] && git_status=" $git_status"
    echo -n "$git_up_status$git_status"
  fi
}

git_status_prompt() {
  [[ -z "$DISABLE_GIT_PROMPT" ]] || return
  [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || return

  local git_branch="$(git_current_branch)"
  [[ -z "$git_branch" ]] && return

  echo -n "$ZSH_THEME_GIT_PROMPT_PREFIX%F{yellow}%B${git_branch}%b%f%F{red}%B$(git_status)%b%f$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

[[ ! -z "$container" ]] && ZSH_STATUS_CONTAINER="%F{137}($container)%f"

PROMPT='%(#.%F{red}.%F{white})%B%n%b%f@%F{241}%m%f$ZSH_STATUS_CONTAINER:%F{blue}%B%c/%b%f $(git_status_prompt)%1(j.%F{white}[%j]%f .)%(?.%F{66}.%F{9})%B%(#.#.$)%b%f '

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%F{blue}%B(%b%f"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{blue}%B)%f%b "

ZSH_GIT_STATUS_UNTRACKED="${ZSH_GIT_STATUS_UNTRACKED="…"}"
ZSH_GIT_STATUS_MODIFIED="${ZSH_GIT_STATUS_MODIFIED="✗"}"
ZSH_GIT_STATUS_STASHED="${ZSH_GIT_STATUS_STASHED="√"}"
ZSH_GIT_STATUS_AHEAD="${ZSH_GIT_STATUS_AHEAD="⇡"}"
ZSH_GIT_STATUS_BEHIND="${ZSH_GIT_STATUS_BEHIND="⇣"}"
ZSH_GIT_STATUS_DIVERGED="${ZSH_GIT_STATUS_DIVERGED="⇕"}"

LSCOLORS=ExgxcxcxbxDxDxBhBhagAg
LS_COLORS='di=1;34:ln=36:so=32:pi=32:ex=31:bd=1;33:cd=1;33:su=1;31;47:sg=1;31;47:tw=30;46:ow=1;30;46'
