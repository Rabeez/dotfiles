#!/usr/bin/env bash
# colorize.sh — pipe extract.sh through the awk colorizer.
# Reads THEME from ~/.local/state/theme-mode (dark|light), defaults to dark.
set -euo pipefail

theme_file="$HOME/.local/state/theme-mode"
if [[ -r "$theme_file" ]]; then
	THEME=$(tr -d '[:space:]' <"$theme_file")
else
	THEME=dark
fi
export THEME

exec awk -f "$(dirname "$0")/colorize.awk"
