#!/usr/bin/env bash
# Runs on pane.agent_detected.
# Pushes a $agent pane metadata token with a nerd icon prefix.

set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
pane_id="${HERDR_PANE_ID:-}"
[ -n "$pane_id" ] || exit 0

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"
agent=""
if [[ $ctx =~ \"focused_pane_status\":\"([^\"]+)\" ]]; then
  : # status, not name
fi
# Extract agent name from the event JSON
evt="${HERDR_PLUGIN_EVENT_JSON:-}"
if [[ $evt =~ \"agent\":\"([^\"]+)\" ]]; then
  agent="${BASH_REMATCH[1]}"
fi
# Fallback: try context
if [ -z "$agent" ] && [[ $ctx =~ \"focused_pane_status\":\"([^\"]+)\" ]]; then
  : # not useful
fi

[ -n "$agent" ] || exit 0

# Prefix with a placeholder icon — replace X on line 29 with your nerd icon
label="󱙺  $agent"

"$herdr" pane report-metadata "$pane_id" \
  --source rabeez.workspace \
  --token "agent=$label" >/dev/null 2>&1 || true
