#!/usr/bin/env bash
# Runs on workspace.focused and workspace.created.
#
# Jobs:
#   1. Maintain an MRU stack of workspace ids in the plugin state dir, so
#      last-workspace.sh can toggle between the two most recent workspaces.
#   2. Move the focused workspace to position 0 in the sidebar (MRU sort).
#      Uses the socket API directly since `herdr workspace move` has no CLI.
#   3. Stamp the workspace with a `dir` metadata token holding its shortened
#      cwd. WorkspaceInfo has no cwd field and there is no cwd sidebar token,
#      so this is the only way to show the working directory in the sidebar.
#      The project picker also dedupes on it, which is what makes multiple
#      workspaces inside one monorepo work correctly.
#
# Pass --no-mru to skip MRU update and sidebar sort (used for workspace.created,
# where the workspace is not necessarily focused yet).

set -uo pipefail

no_mru=0
[ "${1:-}" = "--no-mru" ] && no_mru=1

herdr="${HERDR_BIN_PATH:-herdr}"
ws="${HERDR_WORKSPACE_ID:-}"
[ -n "$ws" ] || exit 0

state_dir="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr/plugins/rabeez.workspace}"
mkdir -p "$state_dir" 2>/dev/null
mru="$state_dir/mru"

# --- 1. MRU stack ----------------------------------------------------------
if [ "$no_mru" -eq 0 ]; then
  prev=""
  [ -r "$mru" ] && IFS= read -r prev < "$mru"
  if [ "$prev" != "$ws" ]; then
    # current on line 1, previous on line 2
    printf '%s\n%s\n' "$ws" "$prev" > "$mru"
  fi

  # --- 2. MRU sort: move focused workspace to top of sidebar ---------------
  # Uses the socket API (workspace.move with insert_index=0) since there's no
  # CLI command for this. One NDJSON request per connection, <1ms latency.
  sock="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
  if [ -S "$sock" ]; then
    python3 -c "
import socket, json, sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    s.connect(sys.argv[1])
    req = json.dumps({'id':'mru-sort','method':'workspace.move','params':{'workspace_id':sys.argv[2],'insert_index':0}}) + '\n'
    s.sendall(req.encode())
    s.settimeout(1)
    s.recv(4096)
except: pass
finally: s.close()
" "$sock" "$ws" 2>/dev/null &
  fi
fi

# --- 2. dir metadata token -------------------------------------------------
# Extract cwd from the plugin context JSON (HERDR_ACTIVE_PANE_CWD is NOT set
# for event hooks; cwd lives in HERDR_PLUGIN_CONTEXT_JSON.focused_pane_cwd).
cwd=""
ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"
if [ -n "$ctx" ]; then
  # Pure bash JSON extraction — no jq fork for latency.
  if [[ $ctx =~ \"focused_pane_cwd\":\"([^\"]+)\" ]]; then
    cwd="${BASH_REMATCH[1]}"
  elif [[ $ctx =~ \"workspace_cwd\":\"([^\"]+)\" ]]; then
    cwd="${BASH_REMATCH[1]}"
  fi
fi
# Fallback: query the workspace's first pane
if [ -z "$cwd" ]; then
  pane_info=$("$herdr" pane list 2>/dev/null)
  if [[ $pane_info =~ \"workspace_id\":\"$ws\".*\"cwd\":\"([^\"]+)\" ]]; then
    cwd="${BASH_REMATCH[1]}"
  fi
fi
[ -n "$cwd" ] || exit 0

# Shorten to just the last directory name so the sidebar stays compact.
# ~/Documents/Programming/data-science -> data-science
# ~/Downloads -> Downloads
# ~ -> ~
short="${cwd/#$HOME/\~}"
if [ "$short" = "~" ]; then
  short="~"
else
  short="${short##*/}"
fi

"$herdr" workspace report-metadata "$ws" \
  --source rabeez.workspace \
  --token "dir=  $short" >/dev/null 2>&1 || true

# --- 3. git metadata token ------------------------------------------------
# Combine the branch icon (U+EC6F ) with the branch name and basic status,
# replacing herdr's built-in `branch` and `git_status` tokens with a single
# `$git` token that carries the nerd icon.
git_str=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Count ahead/behind
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    ab=""
    if [ -n "$upstream" ]; then
      ahead=$(git -C "$cwd" rev-list --count '@{upstream}..HEAD' 2>/dev/null)
      behind=$(git -C "$cwd" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
      [ "${behind:-0}" -gt 0 ] && ab="↓${behind}"
      [ "${ahead:-0}" -gt 0 ] && ab="${ab}↑${ahead}"
    fi
    # Dirty indicator
    dirty=""
    git -C "$cwd" diff --quiet HEAD -- 2>/dev/null || dirty=" *"
    git_str=$'󰘬 '" ${branch}${ab:+ ${ab}}${dirty}"
  fi
fi

if [ -n "$git_str" ]; then
  "$herdr" workspace report-metadata "$ws" \
    --source rabeez.workspace \
    --token "git=$git_str" >/dev/null 2>&1 || true
fi

# --- 4. pane-level $dir token for agent sidebar rows ----------------------
# Agent rows use pane metadata, not workspace metadata, so $dir needs to be
# stamped on each pane for the agents section to display it.
pane_id="${HERDR_PANE_ID:-}"
if [ -n "$pane_id" ] && [ -n "$short" ]; then
  "$herdr" pane report-metadata "$pane_id" \
    --source rabeez.workspace \
  --token "dir=  $short" >/dev/null 2>&1 || true
fi
