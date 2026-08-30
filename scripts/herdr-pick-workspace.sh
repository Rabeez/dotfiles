#!/usr/bin/env bash
# Workspace switcher for herdr (bound to prefix+w, and cmd+l from kitty).
#
# The herdr equivalent of `sesh list -t`: lists workspaces that are currently
# open and focuses the selected one. Use herdr-pick-project.sh (prefix+f) to
# open something that isn't running yet.

set -uo pipefail

# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")/herdr-fzf-common.sh"

command -v herdr >/dev/null 2>&1 || { echo "herdr not found" >&2; sleep 2; exit 1; }
command -v fzf   >/dev/null 2>&1 || { echo "fzf not found" >&2;   sleep 2; exit 1; }
command -v jq    >/dev/null 2>&1 || { echo "jq not found" >&2;    sleep 2; exit 1; }

# id \t label -- id is hidden from display but used for the action.
list=$(herdr workspace list 2>/dev/null \
  | jq -r '.result.workspaces[] | "\(.workspace_id)\t\(.label)"' 2>/dev/null)

if [ -z "$list" ]; then
  echo "No workspaces open." >&2
  sleep 2
  exit 0
fi

FZF_OPTS=()
while IFS= read -r _opt; do FZF_OPTS+=("$_opt"); done < <(_herdr_fzf_opts)

selected=$(printf '%s\n' "$list" \
  | fzf "${FZF_OPTS[@]}" \
        --delimiter='\t' \
        --with-nth=2 \
        --nth=2 \
        --prompt='  ' \
        --no-header) || exit 0

[ -z "$selected" ] && exit 0

ws_id=$(printf '%s' "$selected" | cut -f1)
[ -n "$ws_id" ] && herdr workspace focus "$ws_id" >/dev/null 2>&1
