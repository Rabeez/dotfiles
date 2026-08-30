#!/usr/bin/env bash
# After restore, cd each pane to its saved directory.
# Resurrect with capture-pane-contents uses "exec $SHELL" which can reset CWD.
# This hook forces each shell pane back to its saved path.

resurrect_dir="$HOME/.tmux/resurrect"
last_file="$(readlink -f "$resurrect_dir/last")"
[ -f "$last_file" ] || exit 0

# Wait for all shells to fully initialize (source .zshrc etc).
# 0.5s is too short — login shells + heavy zshrc can take 1-2s per pane.
sleep 3

grep '^pane' "$last_file" | while IFS=$'\t' read -r _ session window _ _ pane_idx _ dir _ cmd _; do
	# Strip leading colon from path
	dir="${dir#:}"
	[ -d "$dir" ] || continue
	# Only send cd to shell panes (not running processes like nvim/lazygit)
	if [[ "$cmd" == "zsh" || "$cmd" == "bash" || "$cmd" == "fish" || "$cmd" == "sh" ]]; then
		# C-c clears any partial input; space prefix avoids polluting history
		tmux send-keys -t "${session}:${window}.${pane_idx}" C-c
		sleep 0.05
		tmux send-keys -t "${session}:${window}.${pane_idx}" " cd \"$dir\" && clear" Enter
	fi
done
