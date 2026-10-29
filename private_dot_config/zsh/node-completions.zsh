zmodload zsh/stat
typeset -gA _node_completion_signatures

_load_node_completion() {
  local tool="$1" executable="$2" dependency="$3"
  shift 3
  local signature="$executable" file cached_signature output temporary
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
  local cache_file="$cache_dir/$tool.zsh"
  local -A metadata

  for file in "$executable" "$dependency"; do
    [[ -n "$file" ]] || continue
    zstat -H metadata -- "$file" 2>/dev/null || return 1
    signature+="|${(q)file}:$metadata[inode]:$metadata[size]:$metadata[mtime]:$metadata[ctime]"
  done
  [[ "${_node_completion_signatures[$tool]:-}" == "$signature" ]] && return 0

  if [[ -r "$cache_file" ]]; then
    IFS= read -r cached_signature < "$cache_file"
    if [[ "$cached_signature" == "# $signature" ]]; then
      source "$cache_file" || return 1
      _node_completion_signatures[$tool]="$signature"
      return 0
    fi
  fi

  output=$("$executable" "$@") || return 1
  [[ -n "$output" ]] || return 1
  print -r -- "$output" | zsh -n || return 1
  eval "$output" || return 1
  _node_completion_signatures[$tool]="$signature"

  # Cache writes are optional; completions still work on a read-only filesystem.
  if mkdir -p -m 700 -- "$cache_dir" 2>/dev/null; then
    temporary=$(mktemp "$cache_file.XXXXXX") || return 0
    if { print -r -- "# $signature"; print -r -- "$output"; } > "$temporary"; then
      command mv -f -- "$temporary" "$cache_file" || command rm -f -- "$temporary"
    else
      command rm -f -- "$temporary"
    fi
  fi
  return 0
}

_update_node_completions() {
  local node_path="${commands[node]:-}" npm_path="${commands[npm]:-}" npm_package
  [[ -n "$node_path" || -n "$npm_path" ]] || return 0
  autoload -Uz bashcompinit
  (( $+functions[complete] )) || bashcompinit

  if [[ -n "$node_path" ]]; then
    _load_node_completion node "${node_path:A}" '' --completion-bash
  fi
  if [[ -n "$npm_path" ]]; then
    npm_path="${npm_path:A}"
    npm_package="${npm_path:h:h}/package.json"
    [[ -f "$npm_package" ]] || npm_package=''
    _load_node_completion npm "$npm_path" "$npm_package" completion
  fi
  return 0
}
