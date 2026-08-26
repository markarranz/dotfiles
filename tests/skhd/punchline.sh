#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"

# shellcheck source=/dev/null
source "$repo_root/private_dot_config/skhd/punchline.sh"

pause='<break time="1.0s" />'
failures=0

assert_pause() {
  local input expected actual
  input="$1"
  expected="$2"
  actual="$(dad_joke_with_punchline_pause "$input")"

  if [ "$actual" != "$expected" ]; then
    printf 'input:    %s\nexpected: %s\nactual:   %s\n' "$input" "$expected" "$actual" >&2
    failures=$((failures + 1))
  fi
}

assert_pause "Dad, can you put my shoes on? I don't think they'll fit me." "Dad, can you put my shoes on? $pause I don't think they'll fit me."
assert_pause "What do you call a duck that gets all A's? A wise quacker." "What do you call a duck that gets all A's? $pause A wise quacker."
assert_pause "What did the green grape say to the purple grape? BREATH!!" "What did the green grape say to the purple grape? $pause BREATH!!"
assert_pause "Why do pirates not know the alphabet? They always get stuck at C." "Why do pirates not know the alphabet? $pause They always get stuck at C."
assert_pause "What do you get when you cross a chicken with a skunk? A fowl smell!" "What do you get when you cross a chicken with a skunk? $pause A fowl smell!"

assert_pause "I finally bought the limited edition Thesaurus that I've always wanted. When I opened it, all the pages were blank. I have no words to describe how angry I am." "I finally bought the limited edition Thesaurus that I've always wanted. When I opened it, all the pages were blank. $pause I have no words to describe how angry I am."
assert_pause "I went to the zoo the other day, there was only one dog in it. It was a shitzu." "I went to the zoo the other day, there was only one dog in it. $pause It was a shitzu."
assert_pause "Two satellites decided to get married. The wedding wasn't much, but the reception was incredible." "Two satellites decided to get married. $pause The wedding wasn't much, but the reception was incredible."
assert_pause 'Thanks for explaining the word "many" to me. It means a lot.' "Thanks for explaining the word \"many\" to me. $pause It means a lot."

assert_pause "A ghost walks into a bar and asks for a glass of vodka but the bartender says, sorry we don't serve spirits." "A ghost walks into a bar and asks for a glass of vodka $pause but the bartender says, sorry we don't serve spirits."
assert_pause "At the boxing match, the dad got into the popcorn line and the line for hot dogs, but he wanted to stay out of the punchline." "At the boxing match, the dad got into the popcorn line and the line for hot dogs, $pause but he wanted to stay out of the punchline."
assert_pause "A man got hit in the head with a can of Coke, but he was alright because it was a soft drink." "A man got hit in the head with a can of Coke, $pause but he was alright because it was a soft drink."
assert_pause "I'm practicing for a bug-eating contest and I've got butterflies in my stomach." "I'm practicing for a bug-eating contest $pause and I've got butterflies in my stomach."
assert_pause "I told my computer I needed a break, and now it keeps sending me vacation ads." "I told my computer I needed a break, $pause and now it keeps sending me vacation ads."
assert_pause "In the news a courtroom artist was arrested today, I'm not surprised, he always seemed sketchy." "In the news a courtroom artist was arrested today, I'm not surprised, $pause he always seemed sketchy."

assert_pause "Tuple trigger API check." "Tuple trigger API check."
assert_pause "A short joke." "A short joke."

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'all punchline fixtures passed\n'
