#!/bin/sh
# browser-memory.sh — RAM usage by browser
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for lib in "$SCRIPT_DIR"/lib/*.sh; do . "$lib"; done

require_cmd gum top

# ─────────────────────────────────────────────
# browser-memory.sh — RAM usage by browser
# Groups all subprocesses (renderers, helpers,
# GPU, plugin-containers, etc.) per browser.
# Electron apps are auto-detected and shown
# separately from actual browsers.
#
# Uses macOS `top` for memory measurement, which
# reports physical footprint (same as Activity
# Monitor) — accounts for memory compression,
# shared pages, and purgeable memory.
#
# POSIX sh compatible — no bash required.
# Heavy lifting done in awk for performance.
# ─────────────────────────────────────────────

# human_size KB -> human readable (e.g. "1.5GiB")
human_size() {
	echo "$1" | awk '{
		b = $1 * 1024
		if (b >= 1073741824) printf "%.1fGiB\n", b / 1073741824
		else if (b >= 1048576) printf "%.1fMiB\n", b / 1048576
		else if (b >= 1024) printf "%.1fKiB\n", b / 1024
		else printf "%dB\n", b
	}'
}

# ── Data collection script (runs inside gum spinner) ──
# Writes results to a temp file since gum spin captures stdout.
# The script collects top + ps snapshots and runs a single awk
# invocation that does all PID→browser/Electron matching.
_collect_script=$(mktemp)
_data_out=$(mktemp)
trap 'rm -f "$_collect_script" "$_data_out"' EXIT

cat >"$_collect_script" <<'COLLECT_EOF'
#!/bin/sh
set -eu
_data_out="$1"

_top_data=$(mktemp)
_ps_data=$(mktemp)
trap 'rm -f "$_top_data" "$_ps_data"' EXIT

top -l 1 -stats pid,mem 2>/dev/null | awk 'NR > 12 && NF >= 2 { print $1, $2 }' > "$_top_data"
ps -eo pid=,comm= | awk '{printf "%d\t", $1; for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}' > "$_ps_data"

# All matching logic in a single awk invocation for performance.
# Three-phase input: top data (file), then ps data piped twice
# via a here-document with sentinel lines as phase separators.
# Outputs tab-separated: TYPE NAME KB COUNT
awk '
BEGIN {
	FS = " "
	# Browser definitions — order matters (Canary before Chrome)
	bc = 5
	bn[1] = "Chrome Canary"; bp[1] = "/Applications/Google Chrome Canary.app/"
	bn[2] = "Chrome";        bp[2] = "/Applications/Google Chrome.app/"
	bn[3] = "Firefox";       bp[3] = "/Applications/Firefox.app/"
	bn[4] = "Zen";           bp[4] = "/Applications/Zen.app/"
	bn[5] = "Safari";        bp[5] = "Safari"
	for (i = 1; i <= bc; i++) { totals[bn[i]] = 0; counts[bn[i]] = 0 }

	# Electron indicator patterns
	ec = 6
	ep[1] = "Electron Framework"
	ep[2] = "Helper (Renderer)"
	ep[3] = "Helper (GPU)"
	ep[4] = "Helper (Plugin)"
	ep[5] = "chrome_crashpad_handler"
	ep[6] = "Helper.app"

	eac = 0  # electron app count
	phase = "top"
}

# Phase 1: top output (PID MEM)
phase == "top" && /^---PS_DATA---$/ { phase = "ps1"; next }
phase == "top" {
	pid = $1; mem = $2
	if (pid == "" || mem == "") next
	num = mem; gsub(/[A-Za-z+]/, "", num)
	if (num == "") next
	nv = num + 0
	if (mem ~ /[Gg]/) kb = int(nv * 1048576)
	else if (mem ~ /[Mm]/) kb = int(nv * 1024)
	else if (mem ~ /[Kk]/) kb = int(nv)
	else kb = 0
	mempid[pid] = kb
	next
}

# Phase 2: first ps pass — match browsers and detect Electron apps
phase == "ps1" && /^---PS_PASS2---$/ { phase = "ps2"; next }
phase == "ps1" {
	tab = index($0, "\t")
	if (tab == 0) next
	pid = substr($0, 1, tab - 1)
	comm = substr($0, tab + 1)
	if (pid == "" || comm == "") next
	if (!(pid in mempid)) next
	if (pid in seen) next
	lkb = mempid[pid]

	# Try matching known browsers
	matched = 0
	for (i = 1; i <= bc; i++) {
		if (index(comm, bp[i]) > 0) {
			totals[bn[i]] += lkb; counts[bn[i]]++
			seen[pid] = 1; matched = 1; break
		}
	}
	if (matched) next

	# Auto-detect Electron apps from /Applications/*.app/ bundles
	if (index(comm, "/Applications/") != 1) next
	rest = substr(comm, 15)
	sl = index(rest, "/")
	if (sl == 0) next
	ab = substr(rest, 1, sl - 1)
	if (ab == "") next
	if (!match(ab, /\.app$/)) next

	# Skip known browser bundles
	isbr = 0; tp = "/Applications/" ab "/"
	for (i = 1; i <= bc; i++) { if (index(tp, bp[i]) > 0) { isbr = 1; break } }
	if (isbr) next

	# Check Electron indicators
	isel = 0
	for (i = 1; i <= ec; i++) { if (index(comm, ep[i]) > 0) { isel = 1; break } }
	an = substr(ab, 1, length(ab) - 4)

	if (isel) {
		if (!(an in totals)) {
			totals[an] = 0; counts[an] = 0; eac++; eapps[eac] = an
		}
		totals[an] += lkb; counts[an]++; seen[pid] = 1
	} else if (an in totals) {
		totals[an] += lkb; counts[an]++; seen[pid] = 1
	}
	next
}

# Phase 3: second ps pass — pick up main procs of discovered Electron apps
phase == "ps2" {
	if (eac == 0) next
	tab = index($0, "\t")
	if (tab == 0) next
	pid = substr($0, 1, tab - 1)
	comm = substr($0, tab + 1)
	if (pid in seen) next
	if (!(pid in mempid)) next
	if (index(comm, "/Applications/") != 1) next
	rest = substr(comm, 15)
	sl = index(rest, "/")
	if (sl == 0) next
	ab = substr(rest, 1, sl - 1)
	if (ab == "") next
	if (!match(ab, /\.app$/)) next
	an = substr(ab, 1, length(ab) - 4)
	if (an in totals) {
		totals[an] += mempid[pid]; counts[an]++; seen[pid] = 1
	}
	next
}

END {
	for (i = 1; i <= bc; i++)
		printf "BROWSER\t%s\t%d\t%d\n", bn[i], totals[bn[i]], counts[bn[i]]
	for (i = 1; i <= eac; i++)
		printf "ELECTRON\t%s\t%d\t%d\n", eapps[i], totals[eapps[i]], counts[eapps[i]]
}
' "$_top_data" - <<ENDMARKER > "$_data_out"
---PS_DATA---
$(cat "$_ps_data")
---PS_PASS2---
$(cat "$_ps_data")
ENDMARKER
COLLECT_EOF
chmod +x "$_collect_script"

gum spin --spinner minidot --title "Collecting memory data…" -- sh "$_collect_script" "$_data_out"

# ── Format output ───────────────────────────────────────
_rows=$(mktemp)
_electron_unsorted=$(mktemp)
: >"$_rows"
: >"$_electron_unsorted"
trap 'rm -f "$_collect_script" "$_data_out" "$_rows" "$_electron_unsorted" "${_rows}.bt" "${_rows}.et"' EXIT

browser_total=0
electron_total=0

# Parse awk output (tab-separated: TYPE NAME KB COUNT)
while IFS='	' read -r type name kb count; do
	[ -z "$type" ] && continue
	case "$type" in
	BROWSER)
		[ "$kb" -eq 0 ] 2>/dev/null && continue
		printf '%s\n' "$kb" >>"${_rows}.bt"
		printf '%s|%s|%s processes\n' "$name" "$(human_size "$kb")" "$count" >>"$_rows"
		;;
	ELECTRON)
		[ "$kb" -eq 0 ] 2>/dev/null && continue
		printf '%s\t%s\t%s\n' "$kb" "$name" "$count" >>"$_electron_unsorted"
		;;
	esac
done <"$_data_out"

# Accumulate browser total from side-channel file
# (piped while loops run in subshells in POSIX sh, so we
#  write values to a file and sum them here in the main shell)
if [ -f "${_rows}.bt" ]; then
	while read -r val; do
		browser_total=$((browser_total + val))
	done <"${_rows}.bt"
	rm -f "${_rows}.bt"
fi

# Sort electron apps by memory descending, add to rows
if [ -s "$_electron_unsorted" ]; then
	if [ -s "$_rows" ]; then
		echo "─|─|─" >>"$_rows"
	fi
	sort -rn "$_electron_unsorted" | while IFS='	' read -r kb name count; do
		[ -z "$name" ] && continue
		[ "$kb" -eq 0 ] 2>/dev/null && continue
		printf '%s\n' "$kb" >>"${_rows}.et"
		printf '⚡%s|%s|%s processes\n' "$name" "$(human_size "$kb")" "$count" >>"$_rows"
	done
fi

# Accumulate electron total from side-channel file
if [ -f "${_rows}.et" ]; then
	while read -r val; do
		electron_total=$((electron_total + val))
	done <"${_rows}.et"
	rm -f "${_rows}.et"
fi

if [ ! -s "$_rows" ]; then
	gum style --foreground 242 "No browsers or Electron apps running."
	exit 0
fi

grand_total=$((browser_total + electron_total))
echo "─|─|─" >>"$_rows"
if [ "$browser_total" -gt 0 ]; then
	printf 'Browsers|%s|\n' "$(human_size "$browser_total")" >>"$_rows"
fi
if [ "$electron_total" -gt 0 ]; then
	printf '⚡Electron|%s|\n' "$(human_size "$electron_total")" >>"$_rows"
fi
printf 'TOTAL|%s|\n' "$(human_size "$grand_total")" >>"$_rows"

{
	printf '%s\n' "App|Memory|Processes"
	cat "$_rows"
} | gum table -s '|' -w 20,10,14 -p
