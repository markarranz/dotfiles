#!/usr/bin/env bash
set -euo pipefail

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

error() {
  printf 'play-dad-joke: %s\n' "$*" >&2
}

for cmd in curl say; do
  if ! command_exists "$cmd"; then
    error "missing required command: $cmd"
    exit 1
  fi
done

api_url="${DAD_JOKE_API_URL:-https://icanhazdadjoke.com/}"
blackhole_device="${BLACKHOLE_DEVICE:-BlackHole 2ch}"

joke="$(
  curl -fsS --max-time 5 \
    -H "Accept: text/plain" \
    -H "User-Agent: DotfilesDadJokeShortcut/1.0" \
    "$api_url" |
    tr '\r\n' '  ' |
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
)"

if [ -z "$joke" ]; then
  error "empty joke response"
  exit 1
fi

say -- "$joke" &
local_pid=$!

say -a "$blackhole_device" -- "$joke" &
blackhole_pid=$!

local_status=0
blackhole_status=0
wait "$local_pid" || local_status=$?
wait "$blackhole_pid" || blackhole_status=$?

if [ "$blackhole_status" -ne 0 ]; then
  error "BlackHole output failed for device: $blackhole_device"
fi

exit "$local_status"
