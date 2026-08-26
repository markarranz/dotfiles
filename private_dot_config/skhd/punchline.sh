#!/usr/bin/env bash

dad_joke_trim() {
  local value
  value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

dad_joke_word_count() {
  awk '{ print NF }' <<< "$1"
}

dad_joke_balanced_split() {
  local text setup punchline max_percent punchline_words
  text="$1"
  setup="$2"
  punchline="$3"
  max_percent="$4"
  punchline_words="$(dad_joke_word_count "$punchline")"

  [ "${#setup}" -ge 10 ] &&
    [ "$punchline_words" -ge 3 ] &&
    [ $((100 * ${#punchline})) -le $((max_percent * ${#text})) ]
}

dad_joke_with_punchline_pause() {
  local text setup punchline pattern pivot delimiter
  text="$(dad_joke_trim "$1")"

  if [[ "$text" == *"?"* ]]; then
    setup="$(dad_joke_trim "${text%\?*}?")"
    punchline="$(dad_joke_trim "${text##*\?}")"
    if [ -n "$punchline" ]; then
      printf '%s <break time="1.0s" /> %s\n' "$setup" "$punchline"
      return
    fi
  fi

  if [[ "$text" =~ ^(.+[.!][[:space:]]+)([^.!?]+[.!?]?)$ ]]; then
    setup="$(dad_joke_trim "${BASH_REMATCH[1]}")"
    punchline="$(dad_joke_trim "${BASH_REMATCH[2]}")"
    if dad_joke_balanced_split "$text" "$setup" "$punchline" 60; then
      printf '%s <break time="1.0s" /> %s\n' "$setup" "$punchline"
      return
    fi
  fi

  for pivot in "but" "because" "and now" "and I've" "so"; do
    pattern="^(.+)(,? ${pivot} )(.+)$"
    if [[ "$text" =~ $pattern ]]; then
      setup="$(dad_joke_trim "${BASH_REMATCH[1]}")"
      delimiter="${BASH_REMATCH[2]}"
      punchline="$(dad_joke_trim "${delimiter#,}${BASH_REMATCH[3]}")"
      if [[ "$delimiter" == ,* ]]; then
        setup="${setup},"
      fi
      if dad_joke_balanced_split "$text" "$setup" "$punchline" 60; then
        printf '%s <break time="1.0s" /> %s\n' "$setup" "$punchline"
        return
      fi
    fi
  done

  if [[ "$text" == *,* ]]; then
    setup="$(dad_joke_trim "${text%,*}"),"
    punchline="$(dad_joke_trim "${text##*,}")"
    if dad_joke_balanced_split "$text" "$setup" "$punchline" 45; then
      printf '%s <break time="1.0s" /> %s\n' "$setup" "$punchline"
      return
    fi
  fi

  printf '%s\n' "$text"
}
