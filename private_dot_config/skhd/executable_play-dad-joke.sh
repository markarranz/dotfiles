#!/usr/bin/env bash
set -euo pipefail

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

error() {
  printf 'play-dad-joke: %s\n' "$*" >&2
}

audiotoolbox_device_index() {
  local device_name ffmpeg_output
  device_name="$1"
  ffmpeg_output="$(
    ffmpeg -hide_banner -nostdin \
      -f lavfi -i anullsrc=r=44100:cl=mono \
      -t 0.01 \
      -f audiotoolbox -list_devices true - 2>&1 || true
  )"
  printf '%s\n' "$ffmpeg_output" |
    awk -v device_name="$device_name" '
      match($0, /\[[0-9]+\] /) {
        device_idx = substr($0, RSTART + 1, RLENGTH - 3)
        name = substr($0, RSTART + RLENGTH)
        sub(/^[[:space:]]+/, "", name)
        sub(/,.*/, "", name)
        if (name == device_name) {
          print device_idx
          exit
        }
      }
    '
}

play_to_blackhole() {
  local audio_file device_index
  audio_file="$1"
  device_index="${BLACKHOLE_AUDIO_DEVICE_INDEX:-}"

  if command_exists ffmpeg; then
    if [ -z "$device_index" ]; then
      device_index="$(audiotoolbox_device_index "$blackhole_device")"
    fi
    if [ -n "$device_index" ]; then
      ffmpeg -hide_banner -nostdin -loglevel error \
        -i "$audio_file" \
        -vn \
        -f audiotoolbox \
        -audio_device_index "$device_index" \
        - >/dev/null
      return
    fi
  fi

  return 1
}

play_with_say() {
  local text local_pid blackhole_pid local_status blackhole_status
  text="$1"

  say -- "$text" &
  local_pid=$!

  say -a "$blackhole_device" -- "$text" &
  blackhole_pid=$!

  local_status=0
  blackhole_status=0
  wait "$local_pid" || local_status=$?
  wait "$blackhole_pid" || blackhole_status=$?

  if [ "$blackhole_status" -ne 0 ]; then
    error "BlackHole output failed for device: $blackhole_device"
  fi

  return "$local_status"
}

fallback_with_say() {
  local text
  text="$1"

  if ! command_exists say; then
    error "missing required command: say"
    return 1
  fi

  play_with_say "$text"
}

if ! command_exists curl; then
  error "missing required command: curl"
  exit 1
fi

api_url="${DAD_JOKE_API_URL:-https://icanhazdadjoke.com/}"
blackhole_device="${BLACKHOLE_DEVICE:-BlackHole 2ch}"
elevenlabs_voice_id="${ELEVENLABS_VOICE_ID:-CwhRBWXzGAHq8TQ4Fs17}"
elevenlabs_model_id="${ELEVENLABS_MODEL_ID:-eleven_multilingual_v2}"
elevenlabs_output_format="${ELEVENLABS_OUTPUT_FORMAT:-mp3_44100_128}"
elevenlabs_api_key="${ELEVENLABS_API_KEY:-}"

if [ -z "$elevenlabs_api_key" ] && command_exists security; then
  elevenlabs_keychain_service="${ELEVENLABS_KEYCHAIN_SERVICE:-elevenlabs-api-key}"
  elevenlabs_api_key="$(security find-generic-password -a "$USER" -s "$elevenlabs_keychain_service" -w 2>/dev/null || true)"
fi

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

if [ -z "$elevenlabs_api_key" ]; then
  fallback_with_say "$joke"
  exit $?
fi

for cmd in jq afplay ffmpeg; do
  if ! command_exists "$cmd"; then
    error "missing required command: $cmd"
    exit 1
  fi
done

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/play-dad-joke.XXXXXX")"
audio_file="$tmp_dir/dad-joke.mp3"
error_file="$tmp_dir/elevenlabs-error.txt"

trap 'rm -rf "$tmp_dir"' EXIT

payload="$(
  jq -cn \
    --arg text "$joke" \
    --arg model_id "$elevenlabs_model_id" \
    '{text: $text, model_id: $model_id}'
)"

http_status="$(
  curl -sS --max-time "${ELEVENLABS_TIMEOUT:-30}" \
    -X POST "https://api.elevenlabs.io/v1/text-to-speech/${elevenlabs_voice_id}?output_format=${elevenlabs_output_format}" \
    -H "xi-api-key: ${elevenlabs_api_key}" \
    -H "Accept: audio/mpeg" \
    -H "Content-Type: application/json" \
    --data "$payload" \
    -o "$audio_file" \
    -w "%{http_code}" \
    2>"$error_file" || true
)"

case "$http_status" in
  2*) ;;
  *)
    error "ElevenLabs request failed with HTTP ${http_status}; falling back to say"
    fallback_with_say "$joke"
    exit $?
    ;;
esac

if [ ! -s "$audio_file" ]; then
  error "empty ElevenLabs audio response"
  exit 1
fi

afplay "$audio_file" &
local_pid=$!

play_to_blackhole "$audio_file" &
blackhole_pid=$!

local_status=0
blackhole_status=0
wait "$local_pid" || local_status=$?
wait "$blackhole_pid" || blackhole_status=$?

if [ "$blackhole_status" -ne 0 ]; then
  error "BlackHole output failed for device: $blackhole_device"
fi

exit "$local_status"
