#!/usr/bin/env sh

yabai -m query --spaces |
  jq -c 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[]' |
  xargs -I % yabai -m space --destroy %
