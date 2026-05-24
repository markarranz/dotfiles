#!/bin/sh

set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
notify_script="$script_dir/notify.sh"

usage() {
  cat <<'EOF'
Usage: test-notify.sh [complete|permission|question|error|custom MESSAGE]

Examples:
  test-notify.sh complete
  test-notify.sh permission
  test-notify.sh question
  test-notify.sh error
  test-notify.sh custom "Custom notification body"

Environment:
  NOTIFY_DRY_RUN=1  Print the resolved delivery path instead of sending.
EOF
}

kind="${1-complete}"

case "$kind" in
complete)
  title="OpenCode"
  message="Session complete"
  ;;
permission)
  title="OpenCode"
  message="Permission requested"
  ;;
question)
  title="OpenCode"
  message="Question requested"
  ;;
error)
  title="OpenCode"
  message="Session error"
  ;;
custom)
  if [ "$#" -lt 2 ]; then
    usage >&2
    exit 1
  fi
  title="OpenCode"
  message=$2
  ;;
-h | --help | help)
  usage
  exit 0
  ;;
*)
  usage >&2
  exit 1
  ;;
esac

if [ ! -f "$notify_script" ]; then
  printf '%s\n' "notify helper not found: $notify_script" >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  payload=$(jq -cn \
    --arg title "$title" \
    --arg message "$message" \
    '{title: $title, message: $message}')
else
  escaped_message=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')
  payload=$(printf '{"title":"%s","message":"%s"}' "$title" "$escaped_message")
fi

exec sh "$notify_script" "$payload"
