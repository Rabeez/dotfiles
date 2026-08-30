#!/usr/bin/env bash
# Focus the previously-focused workspace -- a true MRU toggle.
#
# herdr's built-in previous_workspace steps backwards through the workspace
# list positionally, so repeated presses cycle through every workspace instead
# of flipping between the last two. This mirrors tmux's `switch-client -l` /
# `sesh last`: press it twice and you are back where you started.
#
# The MRU stack is maintained by on-focus.sh via the workspace.focused event.

set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
state_dir="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr/plugins/rabeez.workspace}"
mru="$state_dir/mru"

[ -r "$mru" ] || exit 0

current=""
prev=""
{ IFS= read -r current; IFS= read -r prev; } < "$mru" 2>/dev/null

[ -n "$prev" ] || exit 0
[ "$prev" = "$current" ] && exit 0

# Only jump if the target still exists (it may have been closed).
if ! "$herdr" workspace list 2>/dev/null | grep -q "\"workspace_id\":\"$prev\""; then
  exit 0
fi

"$herdr" workspace focus "$prev" >/dev/null 2>&1
# on-focus.sh will fire on workspace.focused and swap the stack, so the next
# press returns here.
