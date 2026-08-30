#!/usr/bin/env bash
# herdr-bootstrap-workspaces.sh
#
# Idempotent: stops the server, wipes session state, restarts, and recreates
# workspaces/tabs/panes from scratch. Safe to run repeatedly.
#
# This is a template — edit the Paths / workspace list section below to match
# the projects you actually want to open on herdr startup.
#
# Layout convention (matching tmux):
#   3-pane = left half | right-top / right-bottom
#   Splits: first split right (50%), then split the right pane down (50%)
#
# API response format (herdr JSON):
#   workspace create -> .result.workspace.workspace_id, .result.root_pane.pane_id
#   pane split       -> .result.pane.pane_id
#   pane current     -> .result.pane.pane_id
#   workspace list   -> .result.workspaces[].workspace_id / .label
#   tab create       -> .result.root_pane.pane_id

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Clean slate — stop server, delete session files, restart
# ---------------------------------------------------------------------------
echo "Stopping herdr server (if running)..."
herdr server stop 2>/dev/null || true
sleep 1

echo "Deleting session files..."
rm -f ~/.config/herdr/session.json ~/.config/herdr/session-history.json

echo "Starting herdr..."
# Launch herdr in the kitty terminal (it needs a TTY).
# If already inside herdr/kitty, `herdr` will just attach; otherwise we poke
# kitty via osascript to start it.
if [[ -n "${HERDR_SESSION:-}" ]]; then
	# Already inside herdr — server will auto-start on next attach
	:
else
	osascript -e 'tell application "kitty" to activate' 2>/dev/null || true
	sleep 1
	osascript 2>/dev/null <<-'EOF' || true
		tell application "System Events"
		    tell process "kitty"
		        keystroke "herdr" & return
		    end tell
		end tell
	EOF
fi

# --- Wait for herdr server ---
wait_for_server() {
	local i=0
	while ! herdr workspace list &>/dev/null; do
		sleep 0.5
		((i++))
		if ((i > 40)); then
			echo "ERROR: herdr server not responding after 20s" >&2
			exit 1
		fi
	done
}

wait_for_server
echo "Server ready."

# --- Helpers ---

# Create workspace, echo workspace_id
create_ws() {
	local cwd="$1" label="$2"
	herdr workspace create --cwd "$cwd" --label "$label" --no-focus 2>&1 \
		| jq -r '.result.workspace.workspace_id'
}

# Create workspace, focus it, split into 3-pane layout
# Args: cwd label [right_cwd] [bottom_cwd]
create_ws_3pane() {
	local cwd="$1" label="$2"
	local right_cwd="${3:-}" bottom_cwd="${4:-}"

	local result ws pane
	result=$(herdr workspace create --cwd "$cwd" --label "$label" --no-focus 2>&1)
	ws=$(echo "$result" | jq -r '.result.workspace.workspace_id')
	pane=$(echo "$result" | jq -r '.result.root_pane.pane_id')
	herdr workspace focus "$ws" 2>/dev/null
	sleep 0.2

	# Split right
	local split_args=(--direction right --no-focus)
	[[ -n "$right_cwd" ]] && split_args+=(--cwd "$right_cwd")
	local right_pane
	right_pane=$(herdr pane split "$pane" "${split_args[@]}" 2>&1 | jq -r '.result.pane.pane_id')

	# Split right pane down
	local down_args=(--direction down --no-focus)
	[[ -n "$bottom_cwd" ]] && down_args+=(--cwd "$bottom_cwd")
	herdr pane split "$right_pane" "${down_args[@]}" 2>/dev/null

	echo "$ws"
}

# --- Paths ---
# EDIT THIS SECTION for personal projects.
PROG="$HOME/Programming"

# =========================================================================

echo "Creating workspaces..."

# 1. main — rename the default workspace
echo "Setting up workspace: main"
FIRST_WS=$(herdr workspace list 2>&1 | jq -r '.result.workspaces[0].workspace_id')
herdr workspace rename "$FIRST_WS" "main" 2>/dev/null || true

# 2. dotfiles (3 panes, all same cwd)
echo "Creating workspace: dotfiles"
create_ws_3pane "$HOME/dotfiles" "dotfiles"

# EDIT: add project workspaces below, e.g.:
# echo "Creating workspace: my_project"
# create_ws_3pane "$PROG/my_project" "my_project"

# Focus back to main
herdr workspace focus "$FIRST_WS" 2>/dev/null || true

echo "Done!"
