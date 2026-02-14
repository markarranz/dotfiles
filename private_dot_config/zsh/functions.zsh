function mkcd() {
  mkdir -p "$@" && cd $_
}

# Wrapper function to trigger SketchyBar after specific brew commands
function brew() {
  local target_cmds=("update" "upgrade" "outdated")
  local subcommand="$1"

  command brew "$@"
  local exit_code=$?

  if [[ ${target_cmds[(r)$subcommand]} == $subcommand ]] && [[ $exit_code -eq 0 ]]; then
    if command -v sketchybar >/dev/null 2>&1; then
      sketchybar --trigger brew_update
    fi
  fi

  return $exit_code
}

# List/search aliases (replaces OMZ aliases plugin)
function als() {
  if [[ -n "$1" ]]; then
    alias | sort | grep -i --color=auto "$1"
  else
    alias | sort
  fi
}

#
# Git helper functions (from oh-my-zsh git plugin)
#

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return

  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  local remote
  for remote in origin upstream; do
    ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
    if [[ $ref == $remote/* ]]; then
      echo ${ref#"$remote/"}
      return 0
    fi
  done

  echo master
  return 1
}

function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done
  echo develop
  return 1
}

function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo $ref
}
