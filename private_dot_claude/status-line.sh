#!/bin/bash
# Claude Code status line — receives JSON session data on stdin

# --- Parse input ---
input=$(cat)

if ! command -v jq > /dev/null 2>&1; then
    printf 'status-line: jq required'
    exit 0
fi

{
    read -r model
    read -r cwd
    read -r output_style
    read -r used_pct
    read -r remaining_pct
} < <(echo "$input" | jq -r '
    .model.display_name // "",
    .workspace.current_dir // "",
    .output_style.name // "",
    ((.context_window.used_percentage // "") | tostring),
    ((.context_window.remaining_percentage // "") | tostring)
')

# Yield to built-in "Context left until auto-compact" bar when context is low
if [ -n "$remaining_pct" ]; then
    rp=${remaining_pct%.*}
    if [[ "$rp" =~ ^[0-9]+$ ]] && [ "$rp" -le 20 ]; then
        exit 0
    fi
fi

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

# --- Voice mode (settings.local.json overrides settings.json) ---
voice_indicator=""
for sf in "$HOME/.claude/settings.local.json" "$HOME/.claude/settings.json"; do
    [ -f "$sf" ] || continue
    v=$(jq -r 'if .voice then "\(.voice.enabled // false)\t\(.voice.mode // "")" else empty end' "$sf" 2>/dev/null)
    [ -z "$v" ] && continue
    v_enabled=${v%%$'\t'*}
    v_mode=${v#*$'\t'}
    if [ "$v_enabled" = "true" ]; then
        voice_indicator="󰍬"
        [ "$v_mode" = "tap" ] && voice_indicator="󰍬·"
    fi
    break
done

# --- Worktree detection ---
worktree_name=""
display_dir=""
if [[ "$cwd" == *"/.worktrees/"* ]]; then
    repo_name=$(basename "${cwd%%/.worktrees/*}")
    after="${cwd#*/.worktrees/}"
    worktree_name="${after%%/*}"
    subdir="${after#*/}"
    [ "$subdir" = "$worktree_name" ] && subdir=""
    if [ -n "$subdir" ]; then
        display_dir="${repo_name}/${subdir}"
    else
        display_dir="$repo_name"
    fi
else
    display_dir="${cwd/#$HOME/\~}"
fi

# --- Go module name ---
go_module=""
gomod_dir="$cwd"
for _ in 1 2 3 4; do
    if [ -f "$gomod_dir/go.mod" ]; then
        mod_line=$(grep '^module ' "$gomod_dir/go.mod" 2>/dev/null | head -1)
        if [ -n "$mod_line" ]; then
            go_module=$(basename "${mod_line#module }")
        fi
        break
    fi
    parent=$(dirname "$gomod_dir")
    [ "$parent" = "$gomod_dir" ] && break
    gomod_dir="$parent"
done

# --- Git branch + dirty indicator ---
git_info=""
gc="$G"
dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        if ! git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
            dirty="*"
            gc="$Y"
        fi
        # In a worktree, branch often equals worktree name — show only if different or dirty
        if [ -n "$worktree_name" ]; then
            if [ -n "$dirty" ]; then
                git_info=" ${dirty}"
            fi
        else
            git_info=" (${branch}${dirty})"
        fi
    fi
fi

# --- Context usage color ---
uc="$S"
if [ -n "$used_pct" ]; then
    pi=${used_pct%.*}
    if [[ "$pi" =~ ^[0-9]+$ ]]; then
        if [ "$pi" -ge 80 ]; then uc="$R"
        elif [ "$pi" -ge 60 ]; then uc="$Y"
        fi
    fi
fi

# --- Compose output ---
s="${M}${model}${X}"

if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    s="${s} ${P}[${output_style}]${X}"
fi

if [ -n "$voice_indicator" ]; then
    s="${s} ${R}${voice_indicator}${X}"
fi

s="${s} ${T}in${X} ${O}${display_dir}${X}"

if [ -n "$worktree_name" ]; then
    s="${s} ${L}⎇ ${worktree_name}${X}"
fi

if [ -n "$go_module" ]; then
    s="${s} ${S}(${go_module})${X}"
fi

if [ -n "$git_info" ]; then
    s="${s}${gc}${git_info}${X}"
fi

if [ -n "$used_pct" ]; then
    s="${s} ${V}│${X} ${uc}◆ ${used_pct}%${X}"
fi

printf '%b' "$s"
