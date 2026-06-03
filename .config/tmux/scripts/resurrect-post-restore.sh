#!/usr/bin/env bash
# After restore, cd each pane to its saved directory.
# Resurrect saves paths in field 8 (colon-prefixed). This script sends
# `cd <path> && clear` to every shell pane so you land in the right place.

resurrect_dir="$HOME/.tmux/resurrect"
last_file="$(readlink -f "$resurrect_dir/last")"
[ -f "$last_file" ] || exit 0

# Small delay to let panes initialize their shells
sleep 0.5

grep '^pane' "$last_file" | while IFS=$'\t' read -r _ session window _ _ pane_idx _ dir _ cmd _; do
	# Strip leading colon from path
	dir="${dir#:}"
	[ -d "$dir" ] || continue
	# Only send cd to shell panes (not running processes like nvim/lazygit)
	if [[ "$cmd" == "zsh" || "$cmd" == "bash" || "$cmd" == "fish" || "$cmd" == "sh" ]]; then
		tmux send-keys -t "${session}:${window}.${pane_idx}" "cd \"$dir\" && clear" Enter
	fi
done
