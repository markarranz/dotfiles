#!/usr/bin/env bash
set -euo pipefail

icon=$''

read_idle_total() {
  local _cpu user nice system idle iowait irq softirq rest
  read -r _cpu user nice system idle iowait irq softirq rest < /proc/stat
  echo "$idle $((user + nice + system + idle + iowait + irq + softirq))"
}

read -r idle1 total1 <<< "$(read_idle_total)"
sleep 0.4
read -r idle2 total2 <<< "$(read_idle_total)"

didle=$((idle2 - idle1))
dtotal=$((total2 - total1))
usage=0
if [ "$dtotal" -gt 0 ]; then
  usage=$(( (100 * (dtotal - didle)) / dtotal ))
fi

procs=$(ps -eo comm,pcpu --sort=-pcpu --no-headers)
top_proc=$(printf '%s\n' "$procs" | awk 'NR==1{print $1}')

class="normal"
if [ "$usage" -ge 85 ]; then class="critical"
elif [ "$usage" -ge 60 ]; then class="warning"
fi

tooltip=$(printf '%s\n' "$procs" | awk 'NR<=5{printf "%s  %s%%\\n", $1, $2}')

printf '{"text":"%s %s%%  %s","tooltip":"%s","class":"%s"}\n' \
  "$icon" "$usage" "$top_proc" "$tooltip" "$class"
