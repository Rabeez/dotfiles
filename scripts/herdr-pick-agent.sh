#!/usr/bin/env bash
# Agent picker for herdr (bound to prefix+a).
# Lists running agents with their session title and status, fuzzy-pick to focus.

set -uo pipefail

here="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=/dev/null
. "$here/herdr-fzf-common.sh"

command -v herdr >/dev/null 2>&1 || { echo "herdr not found" >&2; sleep 2; exit 1; }
command -v fzf   >/dev/null 2>&1 || { echo "fzf not found" >&2;   sleep 2; exit 1; }
command -v jq    >/dev/null 2>&1 || { echo "jq not found" >&2;    sleep 2; exit 1; }

list=$(herdr agent list 2>/dev/null \
  | jq -r '.result.agents[]
           | "\(.pane_id)\t\(.agent // "-")\t\(.terminal_title_stripped // .terminal_title // "-")\t\(.agent_status // "-")"' 2>/dev/null)

if [ -z "$list" ]; then
  echo "No agents running." >&2
  sleep 2
  exit 0
fi

FZF_OPTS=()
while IFS= read -r _opt; do FZF_OPTS+=("$_opt"); done < <(_herdr_fzf_opts)

selected=$(printf '%s\n' "$list" \
  | fzf "${FZF_OPTS[@]}" \
        --delimiter='\t' \
        --with-nth='{2} · {4}  {3}' \
        --nth=2,3,4 \
        --prompt='  ' \
        --no-header) || exit 0

[ -z "$selected" ] && exit 0

pane_id=$(printf '%s' "$selected" | cut -f1)
[ -n "$pane_id" ] && herdr pane focus --pane "$pane_id" >/dev/null 2>&1
