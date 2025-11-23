#!/usr/bin/env zsh

# Trigger the brew_udpate event when brew update or upgrade is run from cmdline
# e.g. via function in .zshrc

brew=(
  label="?"
  icon=􀐛
  padding_right=10
  script="$PLUGIN_DIR/brew.zsh"
)

sketchybar --add event brew_update \
           --add item brew right   \
           --set brew "${brew[@]}" \
           --subscribe brew brew_update

