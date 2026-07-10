#!/usr/bin/env bash
set -euo pipefail
umask 077

vol=$(osascript -e 'input volume of (get volume settings)')
state_dir="$HOME/Library/Caches/com.user.mic-monitor"
mic_vol_file="$state_dir/mic-volume"
muted=0

if [ "$vol" -gt 0 ]; then
	mkdir -p "$state_dir"
	tmp_file=$(mktemp "$state_dir/mic-volume.XXXXXX")
	printf '%s\n' "$vol" >"$tmp_file"
	mv "$tmp_file" "$mic_vol_file"
	osascript -e "set volume input volume 0"
	muted=1
else
	restore_vol=50
	if [ -f "$mic_vol_file" ]; then
		restore_vol=$(cat "$mic_vol_file")
		case "$restore_vol" in
			''|*[!0-9]*) restore_vol=50 ;;
		esac
		if [ "$restore_vol" -lt 1 ] || [ "$restore_vol" -gt 100 ]; then
			restore_vol=50
		fi
	fi
	osascript -e "set volume input volume $restore_vol"
fi

sketchybar --trigger mic_mute_changed "MUTED=$muted" || true
