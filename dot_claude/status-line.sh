#!/bin/bash
# Claude Code status line — receives JSON session data on stdin

# --- Parse input ---
input=$(cat)

if ! command -v jq > /dev/null 2>&1; then
    printf 'status-line: jq required'
    exit 0
fi

model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
    printf '%s' "${model:-claude}"
    exit 0
fi

# --- Catppuccin Mocha palette ---
M='\e[38;2;203;166;247m'   # Mauve
P='\e[38;2;245;194;231m'   # Pink
O='\e[38;2;250;179;135m'   # Peach
G='\e[38;2;166;227;161m'   # Green
Y='\e[38;2;249;226;175m'   # Yellow
S='\e[38;2;137;220;235m'   # Sky
R='\e[38;2;243;139;168m'   # Red
T='\e[38;2;166;173;200m'   # Subtext
V='\e[38;2;127;132;156m'   # Overlay
L='\e[38;2;180;190;254m'   # Lavender
X='\e[0m'                   # Reset

# --- Git branch + dirty indicator ---
git_info=""
gc="$G"

if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=""
        if ! git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
            dirty="*"
            gc="$Y"
        fi

        git_info=" (${branch}${dirty})"
    fi
fi

# --- Context usage color ---
cc="$S"
if [ -n "$used_pct" ]; then
    pi=${used_pct%.*}
    if [[ "$pi" =~ ^[0-9]+$ ]]; then
        if [ "$pi" -ge 80 ]; then cc="$R"
        elif [ "$pi" -ge 60 ]; then cc="$Y"
        fi
    fi
fi

# --- Compose output ---
s="${M}${model}${X}"

if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    s="${s} ${P}[${output_style}]${X}"
fi

s="${s} ${T}in${X} ${O}$(basename "$cwd")${X}"

if [ -n "$git_info" ]; then
    s="${s}${gc}${git_info}${X}"
fi

if [ -n "$used_pct" ]; then
    s="${s} ${V}│${X} ${cc}◆ ${used_pct}%${X}"
fi

printf '%b' "$s"
