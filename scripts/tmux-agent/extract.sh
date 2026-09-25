#!/usr/bin/env bash
# extract.sh — emit a TAB-separated plain-text table of OpenCode agent panes.
#
# Columns (tab-separated, no color, no padding):
#   1. pane_id           e.g. %64 (kept for action step; hidden in picker)
#   2. agent             "* opencode" if current pane, else "  opencode"
#   3. state             BUSY | IDLE | WAIT | DONE | UNKNOWN
#   4. dirname           basename of the session's project dir (or pane cwd)
#   5. tmux_session      from #{session_name}
#   6. title             OpenCode session title (or "—" if not resolvable)
#   7. mru_key           numeric sort key (time_updated); 0 if unknown
#
# Discovery: iterate every tmux pane whose current command is opencode(.exe).
# Session-id resolution (in order):
#   (A) tmux-scout status.json entry keyed "opencode-ses_XXX" for this tmuxPane
#       (works when the OpenCode plugin has fired at least one session event
#       for the currently-running process).
#   (B) Otherwise, walk the pane's process descendants and read command lines
#       via `ps -o command=`; extract `-s ses_XXX` / `--session ses_XXX`.
#       This is the standard mechanism scout itself uses for "parent-chain"
#       discovery.
#   (C) Otherwise, title = "—", mru = 0. Pane is still listed.
#
# Phase (state) comes from scout when available, else "UNKNOWN".

set -euo pipefail

DB="$HOME/.local/share/opencode/opencode.db"
SCOUT="$HOME/.tmux-scout/status.json"
CURRENT_PANE="${TMUX_PANE:-}"

# Bash 3.2 has no associative arrays. Maps in this script are represented by
# parallel indexed arrays; this helper returns the matching index in MAP_INDEX.
map_find_index() {
	local needle="$1"
	shift
	local value
	local i=0
	MAP_INDEX=-1
	for value in "$@"; do
		if [[ "$value" == "$needle" ]]; then
			MAP_INDEX=$i
			return 0
		fi
		i=$((i + 1))
	done
	return 0
}

# --- phase → status tag ------------------------------------------------------
# Scout's 8 canonical phases (session-contract.js) are collapsed to 5 display
# tags for the picker:
#   BUSY  = actively processing (running)
#   WAIT  = blocked on user input (approval or answer) — needs attention
#   IDLE  = discovered, no session events yet
#   DONE  = latest turn finished (completed or interrupted)
#   DEAD  = process/pane gone (crashed or stale)
phase_to_tag() {
	case "$1" in
		running)                             echo BUSY ;;
		waitingForApproval|waitingForAnswer) echo WAIT ;;
		idle)                                echo IDLE ;;
		completed|interrupted)               echo DONE ;;
		crashed|stale)                       echo DEAD ;;
		*)                                   echo UNKNOWN ;;
	esac
}

# --- sqlite lookup (batched) ------------------------------------------------
# Given a list of session ids on stdin (one per line), emit tab-separated
#   sid \t title \t directory \t time_updated
# for every session found. Uses a single sqlite process — cost is roughly
# constant regardless of the number of ids.
sqlite_lookup_batch() {
	[[ ! -r "$DB" ]] && return 0
	# Build a `WHERE id IN ('a','b',...)` clause by feeding ids through awk.
	awk '
		BEGIN { printf "SELECT id, title, directory, time_updated FROM session WHERE id IN (" }
		{
			gsub(/'\''/, "\x27\x27")  # escape embedded single quotes → doubled
			if (NR > 1) printf ","
			printf "'\''%s'\''", $0
		}
		END { print ");" }
	' | sqlite3 -separator $'\t' "$DB" 2>/dev/null
}

# --- process table cache -----------------------------------------------------
# One-shot `ps` parse into two maps used everywhere below:
#   ppid -> "pid1 pid2 ..."   (for descendants walking)
#   pid  -> "ses_XXX"         (only when the command line contains a session
#                              id — this is all we ever need from commands)
# Awk pre-filters ses_XXX so the bash loop only has to iterate one line per
# process with a compact record. That keeps the loop under ~60 ms on macOS.
PROC_CHILDREN_KEYS=()
PROC_CHILDREN_VALUES=()
PROC_SESSION_PIDS=()
PROC_SESSION_IDS=()
_load_proctable() {
	local pid ppid sid
	while read -r pid ppid sid; do
		[[ -z "$pid" ]] && continue
		map_find_index "$ppid" "${PROC_CHILDREN_KEYS[@]-}"
		if (( MAP_INDEX < 0 )); then
			PROC_CHILDREN_KEYS+=("$ppid")
			PROC_CHILDREN_VALUES+=(" $pid")
		else
			PROC_CHILDREN_VALUES[$MAP_INDEX]="${PROC_CHILDREN_VALUES[$MAP_INDEX]} $pid"
		fi
		if [[ -n "$sid" ]]; then
			map_find_index "$pid" "${PROC_SESSION_PIDS[@]-}"
			if (( MAP_INDEX < 0 )); then
				PROC_SESSION_PIDS+=("$pid")
				PROC_SESSION_IDS+=("$sid")
			else
				PROC_SESSION_IDS[$MAP_INDEX]="$sid"
			fi
		fi
	done < <(ps -eo pid=,ppid=,command= | awk '
		{
			pid = $1; ppid = $2; sid = ""
			if (match($0, /(-s|--session)[ \t]+ses_[A-Za-z0-9]+/)) {
				chunk = substr($0, RSTART, RLENGTH)
				if (match(chunk, /ses_[A-Za-z0-9]+/))
					sid = substr(chunk, RSTART, RLENGTH)
			}
			print pid, ppid, sid
		}
	')
	return 0
}
_load_proctable

# --- walk descendants of a PID (DFS, depth-limited), in-memory -------------
descendants() {
	local root="$1" depth="${2:-5}"
	(( depth <= 0 )) && return 0
	map_find_index "$root" "${PROC_CHILDREN_KEYS[@]-}"
	local kids=""
	(( MAP_INDEX >= 0 )) && kids="${PROC_CHILDREN_VALUES[$MAP_INDEX]}"
	local k
	for k in $kids; do
		printf '%s\n' "$k"
		descendants "$k" $((depth - 1))
	done
}

# --- for a given pane's shell PID, discover the attached session id -------
# by scanning the cached session id of every descendant.
discover_session_from_ps() {
	local pane_pid="$1"
	local pids=("$pane_pid") d
	while read -r d; do pids+=("$d"); done < <(descendants "$pane_pid" 5)
	local p sid
	for p in "${pids[@]}"; do
		map_find_index "$p" "${PROC_SESSION_PIDS[@]-}"
		sid=""
		(( MAP_INDEX >= 0 )) && sid="${PROC_SESSION_IDS[$MAP_INDEX]}"
		if [[ -n "$sid" ]]; then
			printf '%s' "$sid"
			return 0
		fi
	done
	return 1
}

# --- preload scout entries: pane_id -> scoutKey and pane_id -> phase -----
SCOUT_PANES=()
SCOUT_KEYS=()
SCOUT_PHASES=()
if [[ -r "$SCOUT" ]]; then
	while IFS=$'\t' read -r pane key phase; do
		[[ -z "$pane" ]] && continue
		map_find_index "$pane" "${SCOUT_PANES[@]-}"
		if (( MAP_INDEX < 0 )); then
			SCOUT_PANES+=("$pane")
			SCOUT_KEYS+=("")
			SCOUT_PHASES+=("")
			MAP_INDEX=$((${#SCOUT_PANES[@]} - 1))
		fi
		# Prefer entries whose key encodes a real session id if multiple exist.
		if [[ "$key" == opencode-ses_* ]] || [[ -z "${SCOUT_KEYS[$MAP_INDEX]}" ]]; then
			SCOUT_KEYS[$MAP_INDEX]="$key"
			SCOUT_PHASES[$MAP_INDEX]="$phase"
		fi
	done < <(jq -r '
		.sessions // {}
		| to_entries[]
		| select(.value.agentType == "opencode")
		| select(.value.tmuxPane != null)
		| [.value.tmuxPane, .key, (.value.phase // "unknown")]
		| @tsv
	' "$SCOUT" 2>/dev/null || true)
fi

# --- main: two-pass to enable batched sqlite -------------------------------
# Pass 1: enumerate live opencode panes, resolve session ids, collect metadata.
declare -a ROW_PANE=() ROW_PID=() ROW_SESS=() ROW_PATH=() ROW_SID=()
while IFS='|' read -r pane pane_pid sess cmd pane_path; do
	case "$cmd" in
		opencode|opencode.exe) ;;
		*) continue ;;
	esac

	sid=""
	map_find_index "$pane" "${SCOUT_PANES[@]-}"
	scout_key=""
	(( MAP_INDEX >= 0 )) && scout_key="${SCOUT_KEYS[$MAP_INDEX]}"
	if [[ "$scout_key" == opencode-ses_* ]]; then
		sid="${scout_key#opencode-}"
	fi
	if [[ -z "$sid" ]]; then
		sid=$(discover_session_from_ps "$pane_pid" || true)
	fi

	ROW_PANE+=("$pane")
	ROW_PID+=("$pane_pid")
	ROW_SESS+=("$sess")
	ROW_PATH+=("$pane_path")
	ROW_SID+=("$sid")
done < <(tmux list-panes -a -F '#{pane_id}|#{pane_pid}|#{session_name}|#{pane_current_command}|#{pane_current_path}' 2>/dev/null || true)

# Pass 2: batched sqlite lookup for all collected session ids.
SID_IDS=()
SID_TITLES=()
SID_DIRS=()
SID_MRUS=()
if (( ${#ROW_SID[@]} > 0 )); then
	# Build unique, non-empty id list
	unique_ids=()
	for s in "${ROW_SID[@]}"; do
		[[ -z "$s" ]] && continue
		map_find_index "$s" "${unique_ids[@]-}"
		(( MAP_INDEX >= 0 )) && continue
		unique_ids+=("$s")
	done
	if (( ${#unique_ids[@]} > 0 )); then
		while IFS=$'\t' read -r sid title dir mru; do
			[[ -z "$sid" ]] && continue
			SID_IDS+=("$sid")
			SID_TITLES+=("$title")
			SID_DIRS+=("$dir")
			SID_MRUS+=("$mru")
		done < <(printf '%s\n' "${unique_ids[@]}" | sqlite_lookup_batch)
	fi
fi

# Pass 3: emit rows.
for ((i = 0; i < ${#ROW_PANE[@]}; i++)); do
	pane="${ROW_PANE[$i]}"
	sess="${ROW_SESS[$i]}"
	pane_path="${ROW_PATH[$i]}"
	sid="${ROW_SID[$i]}"

	title="—"
	dir=""
	mru=0
	map_find_index "$sid" "${SID_IDS[@]-}"
	if [[ -n "$sid" ]] && (( MAP_INDEX >= 0 )) && [[ -n "${SID_TITLES[$MAP_INDEX]}" ]]; then
		title="${SID_TITLES[$MAP_INDEX]}"
		dir="${SID_DIRS[$MAP_INDEX]}"
		mru="${SID_MRUS[$MAP_INDEX]:-0}"
		[[ -z "$title" ]] && title="—"
		[[ -z "$mru" ]]   && mru=0
	fi
	[[ -z "$dir" ]] && dir="$pane_path"

	dirname="${dir##*/}"
	[[ -z "$dirname" ]] && dirname="—"

	map_find_index "$pane" "${SCOUT_PANES[@]-}"
	phase="unknown"
	(( MAP_INDEX >= 0 )) && phase="${SCOUT_PHASES[$MAP_INDEX]:-unknown}"
	state=$(phase_to_tag "$phase")

	if [[ "$pane" == "$CURRENT_PANE" ]]; then
		marker="* opencode"
	else
		marker="  opencode"
	fi

	title=${title//$'\t'/ };   title=${title//$'\n'/ }
	sess=${sess//$'\t'/ };     sess=${sess//$'\n'/ }
	dirname=${dirname//$'\t'/ }; dirname=${dirname//$'\n'/ }

	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$pane" "$marker" "$state" "$dirname" "$sess" "$title" "$mru"
done
