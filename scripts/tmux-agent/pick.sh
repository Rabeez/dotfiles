#!/usr/bin/env bash
# pick.sh — tmux OpenCode agent picker.
# Pipeline: extract.sh -> colorize.sh -> sort -> fzf.
# On selection, switches to the chosen pane (across sessions/windows).
#
# Set TMUX_AGENT_TIME=1 to append per-stage millisecond timings to
# ${TMUX_AGENT_TIME_LOG:-/tmp/tmux-agent-pick.time.log}.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
extract="$here/extract.sh"
colorize="$here/colorize.sh"

# --- optional timing --------------------------------------------------------
TIME_ENABLED=${TMUX_AGENT_TIME:-0}
TIME_LOG=${TMUX_AGENT_TIME_LOG:-/tmp/tmux-agent-pick.time.log}
if [[ "$TIME_ENABLED" == 1 ]]; then
	_now() { gdate +%s%3N; }
	T_START=$(_now)
	_log_ts() { echo "$1 $(_now)" >>"$TIME_LOG"; }
	_log_ts start
else
	_log_ts() { :; }
fi

command -v fzf >/dev/null 2>&1 || { echo "fzf not found" >&2; sleep 2; exit 1; }
command -v jq  >/dev/null 2>&1 || { echo "jq not found"  >&2; sleep 2; exit 1; }
_log_ts prereq_done

# --- theme-aware fzf colors --------------------------------------------------
_fzf_opts() {
	local mode="dark"
	[[ -r "$HOME/.local/state/theme-mode" ]] && mode="$(tr -d '[:space:]' <"$HOME/.local/state/theme-mode")"

	local colors
	if [[ "$mode" == "light" ]]; then
		colors="bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69"
		colors="$colors,header:#d20f39,info:#8839ef,pointer:#dc8a78,marker:#7287fd"
		colors="$colors,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39,border:#9ca0b0"
	else
		colors="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4"
		colors="$colors,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe"
		colors="$colors,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#6c7086"
	fi

	printf '%s\n' \
		--ansi \
		--height=100% \
		--layout=reverse \
		--border=none \
		--info=inline \
		--pointer='▎' \
		--cycle \
		--no-multi \
		--no-sort \
		--color="$colors"
}

# --- gather rows -------------------------------------------------------------
# sort by mru_key (col 7) descending, then hide cols 1 & 7 in fzf
header_file=$(mktemp -t tmux-agent-header.XXXXXX)
trap 'rm -f "$header_file"' EXIT
export HEADER_FILE="$header_file"

_log_ts pipeline_start
rows=$("$extract" | "$colorize" | sort -t $'\t' -k7,7 -nr)
_log_ts pipeline_done

if [[ -z "$rows" ]]; then
	echo "No OpenCode agent panes found." >&2
	sleep 2
	exit 0
fi

header_line=""
[[ -s "$header_file" ]] && header_line=$(<"$header_file")

FZF_OPTS=()
while IFS= read -r opt; do FZF_OPTS+=("$opt"); done < <(_fzf_opts)

# fzf --bind='start:...' fires after fzf has drawn its initial UI. We use it
# to record the "first paint" timestamp when timing is enabled.
FZF_TIMING_BIND=()
if [[ "$TIME_ENABLED" == 1 ]]; then
	FZF_TIMING_BIND=(--bind "start:execute-silent(echo fzf_first_paint \$(gdate +%s%3N) >>$TIME_LOG)")
fi

_log_ts fzf_launch
selected=$(printf '%s\n' "$rows" \
	| fzf "${FZF_OPTS[@]}" "${FZF_TIMING_BIND[@]}" \
	      --delimiter=$'\t' \
	      --with-nth='{2}  {3}  {4}  {5}  {6}' \
	      --nth=2,3,4,5,6 \
	      --prompt='  ' \
	      --header="$header_line" \
	      --header-first) || { _log_ts fzf_exit_no_select; exit 0; }
_log_ts fzf_selected

[[ -z "$selected" ]] && exit 0

pane_id=$(printf '%s' "$selected" | cut -f1)
[[ -z "$pane_id" ]] && exit 0

# Switch focus. `switch-client` handles cross-session; the pane_id is unique
# across all sessions so select-window/select-pane resolve unambiguously.
tmux switch-client -t "$pane_id" 2>/dev/null || true
tmux select-window -t "$pane_id" 2>/dev/null || true
tmux select-pane   -t "$pane_id" 2>/dev/null || true
