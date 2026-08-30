#!/bin/sh
# Claude Code status line — Catppuccin Mocha palette
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Catppuccin Mocha ANSI approximations (256-color)
# mauve (#cba6f7) → 183, green (#a6e3a1) → 157, peach (#fab387) → 216
# red (#f38ba8) → 211, subtext0 (#a6adc8) → 146, teal (#94e2d5) → 116

CLR_MAUVE='\033[38;5;183m'
CLR_GREEN='\033[38;5;157m'
CLR_PEACH='\033[38;5;216m'
CLR_RED='\033[38;5;211m'
CLR_TEAL='\033[38;5;116m'
CLR_SUB='\033[38;5;146m'
CLR_RESET='\033[0m'

# Shorten cwd: replace $HOME with ~
home="$HOME"
short_cwd="${cwd#"$home"}"
if [ "$short_cwd" != "$cwd" ]; then
    short_cwd="~$short_cwd"
fi

# Context usage indicator
ctx_part=""
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if [ "$used_int" -ge 80 ]; then
        ctx_color="$CLR_RED"
    elif [ "$used_int" -ge 50 ]; then
        ctx_color="$CLR_PEACH"
    else
        ctx_color="$CLR_GREEN"
    fi
    ctx_part=" ${CLR_SUB}ctx:${CLR_RESET}${ctx_color}${used_int}%${CLR_RESET}"
fi

printf "${CLR_MAUVE}%s${CLR_RESET}  ${CLR_TEAL}%s${CLR_RESET}%s" "$short_cwd" "$model" "$ctx_part"
