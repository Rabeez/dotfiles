#!/usr/bin/env bash
# opencode_usage.sh — monthly agent usage report (opencode + ccusage)
#   Default: current month, month-to-date.
#   With -m YYYY-MM: full report for a specific past month.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for lib in "$SCRIPT_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum jq npx sqlite3 awk

# ---------- args ----------
usage() {
	local name
	name=$(basename "$0")
	cat <<EOF
$name: OpenCode + ccusage monthly usage report

Usage: $name [OPTIONS]

Options:
  -m YYYY-MM   Report on a specific past month (e.g. 2026-04).
               If omitted, reports the current month (month-to-date).
               Earliest supported month: 2025-10.
  -ts          Show a monthly time-series: last 6 completed months plus
               the current month marked as MTD.
  -s [N]       List top N sessions (default 15) for the current month, or
               for the month given by -m. Shows date, agent, workspace,
               title, tokens, cost — sorted by tokens desc.
  -h, --help   Show this help message and exit

Data sources:
  opencode stats                    top-level overview + tool usage (current month only)
  ~/.local/share/opencode/*.db      per-provider/model breakdown
  npx ccusage@latest daily/monthly  daily totals, time-series, monthly summaries
EOF
}

TARGET_MONTH=""
MODE="report"
TOP_N=15
while [ $# -gt 0 ]; do
	case "$1" in
		-m)
			TARGET_MONTH="${2:-}"
			shift 2
			;;
		-ts)
			if [ "$MODE" != "report" ]; then
				log_error "-ts cannot be combined with other modes"
				exit 1
			fi
			MODE="timeseries"
			shift
			;;
		-s)
			if [ "$MODE" != "report" ]; then
				log_error "-s cannot be combined with other modes"
				exit 1
			fi
			MODE="sessions"
			# Optional numeric argument
			if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
				TOP_N="$2"
				shift 2
			else
				shift
			fi
			;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			log_error "Unknown argument: $1"
			usage >&2
			exit 1
			;;
	esac
done

if [ "$MODE" = "timeseries" ] && [ -n "$TARGET_MONTH" ]; then
	log_error "-ts and -m are mutually exclusive"
	exit 1
fi

if [ -n "$TARGET_MONTH" ]; then
	# Strict format: zero-padded month between 01-12.
	if ! [[ "$TARGET_MONTH" =~ ^[0-9]{4}-(0[1-9]|1[0-2])$ ]]; then
		log_error "Invalid month format: '$TARGET_MONTH' (expected YYYY-MM, e.g. 2026-04)"
		exit 1
	fi
	if [[ "$TARGET_MONTH" < "2025-10" ]]; then
		log_error "Month $TARGET_MONTH is before earliest supported month 2025-10"
		exit 1
	fi
	if [[ "$TARGET_MONTH" > "$(date +%Y-%m)" ]]; then
		log_error "Month $TARGET_MONTH is in the future"
		exit 1
	fi
fi

# ---------- helpers ----------
section() {
	gum style --bold --underline --foreground 12 "$1"
}

subtle() {
	gum style --faint "$1"
}

# Format big integers with thousand separators
fmt_int() {
	printf "%'d" "$1" 2>/dev/null || echo "$1"
}

# Format tokens as 1.2K / 3.4M / 5.6B
fmt_tokens() {
	awk -v n="$1" 'BEGIN {
		if (n >= 1e9) printf "%.1fB", n/1e9;
		else if (n >= 1e6) printf "%.1fM", n/1e6;
		else if (n >= 1e3) printf "%.1fK", n/1e3;
		else printf "%d", n;
	}'
}

fmt_cost() {
	awk -v n="$1" 'BEGIN { printf "$%.2f", n }'
}

# ---------- -ts mode: 5-month time-series + current-month MTD ----------
if [ "$MODE" = "timeseries" ]; then
	CURRENT_MONTH=$(date +%Y-%m)

	gum style \
		--border double --border-foreground 12 \
		--align center --width 60 --margin "1 2" --padding "1 3" \
		--bold \
		"AGENT USAGE REPORT" \
		"Monthly time-series · last 6 months + current MTD"

	TMP_JSON=$(mktemp -t ccusage-monthly.XXXXXX.json)
	trap 'rm -f "$TMP_JSON"' EXIT

	if [ -t 1 ]; then
		if ! gum spin --spinner minidot --title "Running ccusage monthly..." -- \
			bash -c "npx --yes ccusage@latest monthly --json > '$TMP_JSON' 2>/dev/null"; then
			log_error "ccusage failed"
			exit 1
		fi
	else
		log_info "Running ccusage monthly..."
		if ! npx --yes ccusage@latest monthly --json >"$TMP_JSON" 2>/dev/null; then
			log_error "ccusage failed"
			exit 1
		fi
	fi

	section "Monthly totals"
	echo

	# Build the target list of months: 6 completed months before current, then current month.
	# GNU date "-N months" is DST-safe for month arithmetic.
	MONTHS_LIST=""
	for i in 6 5 4 3 2 1 0; do
		m=$(date -d "${CURRENT_MONTH}-01 -${i} months" +%Y-%m)
		MONTHS_LIST+="${m}"$'\n'
	done

	# Pull all ccusage months into a TSV lookup (period<TAB>tokens<TAB>cost).
	CCUSAGE_TSV=$(jq -r '.monthly[] | [.period, .totalTokens, .totalCost] | @tsv' "$TMP_JSON")

	awk -F'\t' \
		-v months="$MONTHS_LIST" -v data="$CCUSAGE_TSV" -v cur="$CURRENT_MONTH" '
	function fmt(n) {
		if (n >= 1e9) return sprintf("%.1fB", n/1e9);
		if (n >= 1e6) return sprintf("%.1fM", n/1e6);
		if (n >= 1e3) return sprintf("%.1fK", n/1e3);
		return sprintf("%d", n);
	}
	function mkbar(v, mx,   w, b, i) {
		if (mx <= 0) return sprintf("%-20s", "");
		w = int((v/mx)*20 + 0.5);
		b = "";
		for (i=0;i<w;i++) b = b "⣿";
		for (i=w;i<20;i++) b = b " ";
		return b;
	}
	BEGIN {
		# Load ccusage data into maps.
		nd = split(data, dlines, "\n");
		for (i=1; i<=nd; i++) {
			if (dlines[i] == "") continue;
			split(dlines[i], f, "\t");
			tok_of[f[1]] = f[2] + 0; cost_of[f[1]] = f[3] + 0;
		}

		# First pass over target months: resolve values and compute max for bars.
		nm = split(months, mlines, "\n");
		count = 0; mx_cost = 0; mx_tok = 0;
		for (i=1; i<=nm; i++) {
			m = mlines[i]; if (m == "") continue;
			count++;
			tok_row[count] = (m in tok_of) ? tok_of[m] : 0;
			cost_row[count] = (m in cost_of) ? cost_of[m] : 0;
			month_row[count] = m;
			if (tok_row[count] > mx_tok) mx_tok = tok_row[count];
			if (cost_row[count] > mx_cost) mx_cost = cost_row[count];
		}
		if (mx_tok == 0) mx_tok = 1;
		if (mx_cost == 0) mx_cost = 1;

		# Header row (widths match the daily time-series section).
		printf "%-13s  %8s  %-20s  %9s  %-20s\n", "Month", "Tokens", "", "Cost", "";
		printf "%-13s  %8s  %-20s  %9s  %-20s\n", "-------------", "--------", "                    ", "---------", "                    ";

		# Data rows.
		for (i=1; i<=count; i++) {
			m = month_row[i];
			label = (m == cur) ? (m " (MTD)") : m;
			total_tok += tok_row[i]; total_cost += cost_row[i];
			printf "%-13s  %8s  %-20s  %9s  %-20s\n", label, fmt(tok_row[i]), mkbar(tok_row[i], mx_tok), sprintf("$%8.2f", cost_row[i]), mkbar(cost_row[i], mx_cost);
		}
		printf "%-13s  %8s  %-20s  %9s  %-20s\n", "-------------", "--------", "                    ", "---------", "                    ";
		printf "%-13s  %8s  %-20s  %9s  %-20s\n", sprintf("TOTAL %d", count), fmt(total_tok), "", sprintf("$%8.2f", total_cost), "";
	}'
	echo

	subtle "Report generated: $(date +'%Y-%m-%d %H:%M:%S %Z')"
	exit 0
fi

# ---------- -s mode: top N sessions for a month ----------
if [ "$MODE" = "sessions" ]; then
	CURRENT_MONTH=$(date +%Y-%m)

	# Resolve target month (default: current). Reuse the same "current-month" fallthrough as the main report.
	if [ -n "$TARGET_MONTH" ] && [ "$TARGET_MONTH" = "$CURRENT_MONTH" ]; then
		log_warn "$TARGET_MONTH is ongoing — showing MTD sessions"
		TARGET_MONTH=""
	fi

	if [ -n "$TARGET_MONTH" ]; then
		S_MONTH_START="${TARGET_MONTH}-01"
		S_MONTH_END=$(date -d "${S_MONTH_START} +1 month" +%Y-%m-%d)
		S_MONTH_LABEL=$(date -d "$S_MONTH_START" +'%Y %B')
	else
		S_MONTH_START=$(date +%Y-%m-01)
		S_MONTH_END=$(date -d "${S_MONTH_START} +1 month" +%Y-%m-%d)
		S_MONTH_LABEL="$(date -d "$S_MONTH_START" +'%Y %B') (MTD)"
	fi
	S_START_MS=$(($(date -d "$S_MONTH_START" +%s) * 1000))
	S_END_MS=$(($(date -d "$S_MONTH_END" +%s) * 1000))

	gum style \
		--border double --border-foreground 12 \
		--align center --width 60 --margin "1 2" --padding "1 3" \
		--bold \
		"AGENT USAGE REPORT" \
		"Top $TOP_N sessions · $S_MONTH_LABEL"

	OPENCODE_DB="$HOME/.local/share/opencode/opencode.db"
	if [ ! -r "$OPENCODE_DB" ]; then
		log_error "OpenCode DB not readable: $OPENCODE_DB"
		exit 1
	fi

	section "Top $TOP_N sessions by token usage"
	echo

	# Determine terminal width. Try /dev/tty first (correct in pipelines/subshells),
	# fall back to tput/stty/COLUMNS, then a reasonable default.
	TERM_COLS=$( (stty size </dev/tty) 2>/dev/null | awk '{print $2}')
	if [ -z "$TERM_COLS" ] || ! [[ "$TERM_COLS" =~ ^[0-9]+$ ]]; then
		TERM_COLS=$(tput cols 2>/dev/null || true)
	fi
	if [ -z "$TERM_COLS" ] || ! [[ "$TERM_COLS" =~ ^[0-9]+$ ]] || [ "$TERM_COLS" -lt 60 ]; then
		TERM_COLS="${COLUMNS:-160}"
	fi
	if ! [[ "$TERM_COLS" =~ ^[0-9]+$ ]] || [ "$TERM_COLS" -lt 60 ]; then
		TERM_COLS=160
	fi

	# Pull sessions from sqlite; shorten workspace paths to just the leaf dir.
	SESSIONS_TSV=$(sqlite3 -readonly -separator $'\t' "$OPENCODE_DB" "
		SELECT
			strftime('%Y-%m-%d', time_created/1000, 'unixepoch') AS date,
			COALESCE(directory, '') AS dir,
			COALESCE(title, '') AS title,
			(tokens_input + tokens_output + tokens_cache_read + tokens_cache_write) AS total_tokens,
			cost
		FROM session
		WHERE time_created >= $S_START_MS AND time_created < $S_END_MS
		ORDER BY total_tokens DESC
		LIMIT $TOP_N;
	" 2>/dev/null)

	echo "$SESSIONS_TSV" | awk -F'\t' -v cols="$TERM_COLS" '
	function fmt(n) {
		if (n >= 1e9) return sprintf("%.1fB", n/1e9);
		if (n >= 1e6) return sprintf("%.1fM", n/1e6);
		if (n >= 1e3) return sprintf("%.1fK", n/1e3);
		return sprintf("%d", n);
	}
	function leaf_dir(d,   parts, k) {
		# Just the final path component: "/Users/x/Programming/foo" -> "foo"
		k = split(d, parts, "/");
		if (k < 1) return d;
		return parts[k];
	}
	function trunc(s, w) {
		if (length(s) <= w) return s;
		return substr(s, 1, w - 1) "…";
	}
	function repchar(c, n,   s, i) { s=""; for (i=0;i<n;i++) s=s c; return s; }
	{
		n++;
		date[n]=$1; dir[n]=leaf_dir($2); title[n]=$3; tok[n]=$4+0; cost[n]=$5+0;
		if (length(dir[n]) > mx_ws) mx_ws = length(dir[n]);
		if (length(title[n]) > mx_ti) mx_ti = length(title[n]);
	}
	END {
		# Fixed widths: idx(4) + date(10) + tokens(8) + cost(8) = 30
		# Gutters: 5 * 2 = 10.  Fixed total = 40.
		# Remaining for Workspace + Title
		remain = cols - 40;
		if (remain < 30) remain = 30;
		min_ws = 10; min_ti = 20;

		# Try to give each its natural size; if too big, shrink proportionally.
		want_ws = (mx_ws > 0) ? mx_ws : min_ws;
		want_ti = (mx_ti > 0) ? mx_ti : min_ti;
		# Cap workspace at 51 (46 + 5) so a monstrous single dirname doesnt eat all the title space
		if (want_ws > 51) want_ws = 51;
		# Give title some breathing room beyond its natural max.
		want_ti += 8;

		if (want_ws + want_ti <= remain) {
			ws_w = want_ws; ti_w = remain - ws_w;
			# Give leftover to title (dont waste it padding workspace).
			if (ti_w > want_ti) ti_w = want_ti;
		} else {
			# Not enough room. Preserve ratio while respecting minimums.
			ratio = want_ws / (want_ws + want_ti);
			ws_w = int(remain * ratio);
			if (ws_w < min_ws) ws_w = min_ws;
			if (ws_w > remain - min_ti) ws_w = remain - min_ti;
			ti_w = remain - ws_w;
		}

		fmt_row = "%-4s  %-10s  %-" ws_w "s  %-" ti_w "s  %8s  %8s\n";
		printf fmt_row, "#", "Date", "Workspace", "Title", "Tokens", "Cost";
		printf fmt_row, "----", "----------", repchar("-", ws_w), repchar("-", ti_w), "--------", "--------";
		if (n == 0) {
			print "  (no sessions in this month)";
			exit;
		}
		total_tok = 0; total_cost = 0;
		for (i=1; i<=n; i++) {
			total_tok += tok[i]; total_cost += cost[i];
			printf "%-4d  %-10s  %-" ws_w "s  %-" ti_w "s  %8s  %8s\n", \
				i, date[i], trunc(dir[i], ws_w), trunc(title[i], ti_w), fmt(tok[i]), sprintf("$%.2f", cost[i]);
		}
		printf fmt_row, "----", "----------", repchar("-", ws_w), repchar("-", ti_w), "--------", "--------";
		printf "%-4s  %-10s  %-" ws_w "s  %-" ti_w "s  %8s  %8s\n", \
			"", "", "", sprintf("TOP %d TOTAL", n), fmt(total_tok), sprintf("$%.2f", total_cost);
	}
	'
	echo

	subtle "Report generated: $(date +'%Y-%m-%d %H:%M:%S %Z')"
	exit 0
fi

# ---------- date range ----------
CURRENT_MONTH=$(date +%Y-%m)

# If user asked for the current month, warn and fall through to MTD branch.
if [ -n "$TARGET_MONTH" ] && [ "$TARGET_MONTH" = "$CURRENT_MONTH" ]; then
	log_warn "$TARGET_MONTH is ongoing — switching to MTD mode"
	TARGET_MONTH=""
fi

if [ -n "$TARGET_MONTH" ]; then
	IS_HISTORICAL=1
	MONTH_START="${TARGET_MONTH}-01"
	TODAY=$(date -d "${MONTH_START} +1 month -1 day" +%Y-%m-%d)
	# Use UTC so DST transitions don't shave off a day.
	DAY_OF_MONTH=$((($(date -u -d "$TODAY" +%s) - $(date -u -d "$MONTH_START" +%s)) / 86400 + 1))
else
	IS_HISTORICAL=0
	TODAY=$(date +%Y-%m-%d)
	MONTH_START=$(date +%Y-%m-01)
	DAY_OF_MONTH=$(date +%d | sed 's/^0//')
fi

MONTH_LABEL=$(date -d "$MONTH_START" +'%Y %B')
if [ $IS_HISTORICAL -eq 1 ]; then
	PERIOD_LABEL="$MONTH_LABEL"
	HEADER_SUB="$MONTH_LABEL · full month ($DAY_OF_MONTH days)"
else
	PERIOD_LABEL="MTD"
	HEADER_SUB="$MONTH_LABEL · month-to-date · day $DAY_OF_MONTH"
fi

# ---------- header ----------
gum style \
	--border double --border-foreground 12 \
	--align center --width 60 --margin "1 2" --padding "1 3" \
	--bold \
	"AGENT USAGE REPORT" \
	"$HEADER_SUB"

# ---------- opencode summary ----------
if [ $IS_HISTORICAL -eq 0 ]; then
	section "OpenCode — Last $DAY_OF_MONTH days"
	echo
	# Tools defaults to all — cap at 10 and annotate the section title in-line.
	# Also swap opencode's bar glyph (█) to match our own (⣿).
	opencode stats --days "$DAY_OF_MONTH" --tools 10 2>/dev/null \
		| awk '
		/│ *TOOL USAGE *│/ {
			# recenter "TOOL USAGE (top 10)" in the 56-char inner width
			label = "TOOL USAGE (top 10)";
			pad = 56 - length(label);
			left = int(pad/2); right = pad - left;
			printf "│";
			for (i=0;i<left;i++) printf " ";
			printf "%s", label;
			for (i=0;i<right;i++) printf " ";
			printf "│\n";
			next;
		}
		{ gsub(/█/, "⣿"); print }
	'
	echo
else
	log_info "Skipping OpenCode section: 'opencode stats' only supports lookback-from-today, not historical month ranges"
	echo
fi

# ---------- ccusage: fetch once ----------
TMP_JSON=$(mktemp -t ccusage.XXXXXX.json)
trap 'rm -f "$TMP_JSON"' EXIT

if [ -t 1 ]; then
	if ! gum spin --spinner minidot --title "Running ccusage..." -- \
		bash -c "npx --yes ccusage@latest daily --json > '$TMP_JSON' 2>/dev/null"; then
		log_error "ccusage failed"
		exit 1
	fi
else
	log_info "Running ccusage..."
	if ! npx --yes ccusage@latest daily --json >"$TMP_JSON" 2>/dev/null; then
		log_error "ccusage failed"
		exit 1
	fi
fi

# ---------- ccusage: totals ----------
section "ccusage — Totals ($MONTH_START → $TODAY)"
echo

MTD_TOTALS=$(jq -r --arg s "$MONTH_START" --arg e "$TODAY" '
  [.daily[] | select(.period >= $s and .period <= $e)] as $d
  | [
      ($d | length),
      ($d | map(.totalCost) | add // 0),
      ($d | map(.totalTokens) | add // 0),
      ($d | map(.inputTokens) | add // 0),
      ($d | map(.outputTokens) | add // 0),
      ($d | map(.cacheReadTokens) | add // 0),
      ($d | map(.cacheCreationTokens) | add // 0)
    ]
  | @tsv
' "$TMP_JSON")

read -r MTD_DAYS MTD_COST MTD_TOK MTD_IN MTD_OUT MTD_CR MTD_CW <<<"$MTD_TOTALS"

AVG_COST=$(awk -v c="$MTD_COST" -v d="$MTD_DAYS" 'BEGIN { if (d>0) printf "%.2f", c/d; else print 0 }')
PROJ_COST=$(awk -v c="$MTD_COST" -v d="$MTD_DAYS" 'BEGIN { if (d>0) printf "%.2f", (c/d)*30; else print 0 }')

{
	printf "Days active\t%s\n" "$MTD_DAYS"
	printf "Total cost\t%s\n" "$(fmt_cost "$MTD_COST")"
	printf "Avg $/day\t\$%s\n" "$AVG_COST"
	printf "Projected 30d\t\$%s\n" "$PROJ_COST"
	printf "Total tokens\t%s\n" "$(fmt_tokens "$MTD_TOK")"
	printf "Input\t%s\n" "$(fmt_tokens "$MTD_IN")"
	printf "Output\t%s\n" "$(fmt_tokens "$MTD_OUT")"
	printf "Cache read\t%s\n" "$(fmt_tokens "$MTD_CR")"
	printf "Cache write\t%s\n" "$(fmt_tokens "$MTD_CW")"
} | gum table --print --separator=$'\t' --columns "Metric,Value" 2>/dev/null || {
	# fallback if gum table not available
	printf "Days active     : %s\n" "$MTD_DAYS"
	printf "Total cost      : %s\n" "$(fmt_cost "$MTD_COST")"
	printf "Avg \$/day       : \$%s\n" "$AVG_COST"
	printf "Projected 30d   : \$%s\n" "$PROJ_COST"
	printf "Total tokens    : %s\n" "$(fmt_tokens "$MTD_TOK")"
	printf "Input           : %s\n" "$(fmt_tokens "$MTD_IN")"
	printf "Output          : %s\n" "$(fmt_tokens "$MTD_OUT")"
	printf "Cache read      : %s\n" "$(fmt_tokens "$MTD_CR")"
	printf "Cache write     : %s\n" "$(fmt_tokens "$MTD_CW")"
}
echo

# ---------- ccusage: daily time-series ----------
section "Daily time-series ($PERIOD_LABEL)"
echo

# Compute max cost and max tokens for independent bar scaling
MAX_COST=$(jq -r --arg s "$MONTH_START" --arg e "$TODAY" '
  [.daily[] | select(.period >= $s and .period <= $e) | .totalCost] | max // 1
' "$TMP_JSON")
MAX_TOK=$(jq -r --arg s "$MONTH_START" --arg e "$TODAY" '
  [.daily[] | select(.period >= $s and .period <= $e) | .totalTokens] | max // 1
' "$TMP_JSON")

jq -r --arg s "$MONTH_START" --arg e "$TODAY" '
  .daily[] | select(.period >= $s and .period <= $e)
  | [.period, .totalTokens, .totalCost] | @tsv
' "$TMP_JSON" | awk -F'\t' \
	-v mx_cost="$MAX_COST" -v mx_tok="$MAX_TOK" \
	-v month_start="$MONTH_START" -v today="$TODAY" '
function fmt(n) {
	if (n >= 1e9) return sprintf("%.1fB", n/1e9);
	if (n >= 1e6) return sprintf("%.1fM", n/1e6);
	if (n >= 1e3) return sprintf("%.1fK", n/1e3);
	return sprintf("%d", n);
}
function mkbar(v, mx,   w, b, i) {
	if (mx <= 0) return sprintf("%-20s", "");
	w = int((v/mx)*20 + 0.5);
	b = "";
	for (i=0;i<w;i++) b = b "⣿";
	for (i=w;i<20;i++) b = b " ";
	return b;
}
BEGIN {
	printf "%-10s  %8s  %-20s  %9s  %-20s\n", "Date", "Tokens", "", "Cost", "";
	printf "%-10s  %8s  %-20s  %9s  %-20s\n", "----------", "--------", "                    ", "---------", "                    ";
}
{ tok_of[$1] = $2; cost_of[$1] = $3 }
END {
	# Iterate every day from month_start through today (both inclusive)
	# using mktime; expects YYYY-MM-DD.
	split(month_start, sp, "-"); split(today, ep, "-");
	# gawk mktime needs "YYYY MM DD HH MM SS"
	t = mktime(sp[1] " " sp[2] " " sp[3] " 12 00 00");
	t_end = mktime(ep[1] " " ep[2] " " ep[3] " 12 00 00");
	while (t <= t_end) {
		d = strftime("%Y-%m-%d", t);
		tok = (d in tok_of) ? tok_of[d] : 0;
		cost = (d in cost_of) ? cost_of[d] : 0;
		total_tok += tok; total_cost += cost; n++;
		printf "%-10s  %8s  %-20s  %9s  %-20s\n", d, fmt(tok), mkbar(tok, mx_tok), sprintf("$%8.2f", cost), mkbar(cost, mx_cost);
		t += 86400;
	}
	printf "%-10s  %8s  %-20s  %9s  %-20s\n", "----------", "--------", "                    ", "---------", "                    ";
	printf "%-10s  %8s  %-20s  %9s  %-20s\n", sprintf("TOTAL %dd", n), fmt(total_tok), "", sprintf("$%8.2f", total_cost), "";
}
'
echo

# ---------- opencode: model usage (from sqlite, with provider) ----------
section "Model usage ($PERIOD_LABEL)"
echo

OPENCODE_DB="$HOME/.local/share/opencode/opencode.db"
START_MS=$(($(date -d "$MONTH_START" +%s) * 1000))
END_MS=$(($(date -d "$TODAY +1 day" +%s) * 1000))

if [ ! -r "$OPENCODE_DB" ]; then
	log_error "OpenCode DB not readable: $OPENCODE_DB"
	echo
else
	# Build providerID/modelID -> pretty name map from `opencode models --verbose`.
	MODEL_NAMES=$(opencode models --verbose 2>/dev/null | awk '
		function emit() {
			if (provider != "") {
				split(provider, a, "/");
				printf "%s\t%s\t%s\n", a[1], a[2], (name != "" ? name : a[2]);
			}
		}
		/^[a-zA-Z][a-zA-Z0-9._-]*\// { emit(); provider=$0; name=""; next }
		/^  "name":/ { match($0, /"name": "([^"]*)"/, m); if (m[1] != "") name=m[1] }
		END { emit() }
	')

	# Aggregate MTD from sqlite, join with pretty-name map in awk.
	sqlite3 -readonly "$OPENCODE_DB" \
		"SELECT data FROM message WHERE time_created >= $START_MS AND time_created < $END_MS;" 2>/dev/null \
		| jq -sr '
			[.[] | select(.role == "assistant" and .providerID != null)]
			| group_by([.providerID, .modelID])
			| map({
					providerID: .[0].providerID,
					modelID: .[0].modelID,
					cost: (map(.cost) | add),
					input: (map(.tokens.input) | add),
					output: (map(.tokens.output) | add),
					cacheRead: (map(.tokens.cache.read) | add),
					cacheWrite: (map(.tokens.cache.write) | add),
					messages: length,
					tokens: (map(.tokens.input + .tokens.output + .tokens.cache.read + .tokens.cache.write) | add)
				})
			| (map(.tokens) | add // 1) as $total
			| sort_by(-.tokens)[]
			| [.providerID, .modelID, .tokens, ((.tokens / $total) * 100), .cost, .input, .output, .cacheRead, .cacheWrite]
			| @tsv
		' \
		| awk -F'\t' -v names="$MODEL_NAMES" '
			function fmt(n) {
				if (n >= 1e9) return sprintf("%.1fB", n/1e9);
				if (n >= 1e6) return sprintf("%.1fM", n/1e6);
				if (n >= 1e3) return sprintf("%.1fK", n/1e3);
				return sprintf("%d", n);
			}
			BEGIN {
				# load name map: provider<TAB>id<TAB>pretty
				n = split(names, lines, "\n");
				for (i=1; i<=n; i++) {
					if (lines[i] == "") continue;
					split(lines[i], f, "\t");
					map[f[1] "|" f[2]] = f[3];
				}
				printf "%-14s %-28s %8s %6s %10s %8s %8s %8s %8s\n", \
					"Provider", "Model", "Tokens", "%", "Cost", "In", "Out", "CacheR", "CacheW";
				printf "%-14s %-28s %8s %6s %10s %8s %8s %8s %8s\n", \
					"--------------", "----------------------------", "--------", "------", "----------", "--------", "--------", "--------", "--------";
			}
			{
				prov=$1; mid=$2;
				pretty = map[prov "|" mid];
				if (pretty == "") pretty = mid;
				printf "%-14s %-28s %8s %5.1f%% %10s %8s %8s %8s %8s\n", \
					substr(prov,1,14), substr(pretty,1,28), fmt($3), $4, sprintf("$%.2f", $5), fmt($6), fmt($7), fmt($8), fmt($9);
			}
		'
fi
echo

# ---------- cache efficiency ----------
section "Cache efficiency ($PERIOD_LABEL)"
echo
awk -v in_t="$MTD_IN" -v cr="$MTD_CR" -v cw="$MTD_CW" -v out="$MTD_OUT" 'BEGIN {
	total_read = in_t + cr;
	if (total_read > 0) hit = (cr / total_read) * 100; else hit = 0;
	ratio = (cw > 0) ? cr/cw : 0;
	printf "  Cache hit ratio : %.1f%% (cache reads / (input + cache reads))\n", hit;
	printf "  Read/Write cache: %.1fx (%.1fM read per 1M written)\n", ratio, ratio;
	printf "  Output share    : %.2f%% of tokens are generated output\n", (out/(in_t+out+cr+cw))*100;
}'
echo

subtle "Report generated: $(date +'%Y-%m-%d %H:%M:%S %Z')"
