# Wrapper function to trigger SketchyBar after specific brew commands
function brew() {
  local target_cmds=("update" "upgrade" "outdated")
  local subcommand="$1"

  # Run the actual brew command with all arguments
  command brew "$@"
  local exit_code=$?

  # Check if the command was one of our targets
  # and if it finished successfully (exit code 0)
  if [[ ${target_cmds[(r)$subcommand]} == $subcommand ]] && [[ $exit_code -eq 0 ]]; then
    
    # Trigger the event name "brew_update"
    if command -v sketchybar >/dev/null 2>&1; then
      sketchybar --trigger brew_update
    fi
    
  fi

  # Return the original exit code
  return $exit_code
}

