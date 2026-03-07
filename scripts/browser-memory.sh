#!/usr/bin/env bash
set -euo pipefail

if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Install it using: brew install gum" >&2
    exit 1
fi

# ─────────────────────────────────────────────
# browser-memory.sh — RAM usage by browser
# ─────────────────────────────────────────────

BROWSER_NAMES=("Chrome Canary" "Chrome" "Firefox" "Zen" "Safari")
BROWSER_PATTERNS=(
	"/Applications/Google Chrome Canary.app/"
	"/Applications/Google Chrome.app/"
	"/Applications/Firefox.app/"
	"/Applications/Zen.app/"
	"Safari"
)

# ── Key-value store via tmpdir files ──────────
KV_DIR=$(mktemp -d)
trap 'rm -rf "$KV_DIR"' EXIT

_kv_safe() { printf '%s' "$1" | tr -cs 'a-zA-Z0-9_-' '_'; }

kv_set() {
	local store="$KV_DIR/$1"; mkdir -p "$store"
	local safe; safe=$(_kv_safe "$2")
	printf '%s\n' "$3" > "$store/$safe"
	printf '%s\n' "$2" > "$store/${safe}.orig"
}

kv_get() {
	local f="$KV_DIR/$1/$(_kv_safe "$2")"
	[[ -f "$f" ]] && cat "$f" || echo 0
}

kv_has() { [[ -f "$KV_DIR/$1/$(_kv_safe "$2")" ]]; }

kv_inc() {
	local cur; cur=$(kv_get "$1" "$2")
	kv_set "$1" "$2" $((cur + $3))
}

# ── PID tracking ──────────────────────────────
SEEN_DIR="$KV_DIR/seen"
mkdir -p "$SEEN_DIR"
seen_pid() { [[ -f "$SEEN_DIR/$1" ]]; }
mark_pid() { touch "$SEEN_DIR/$1"; }

# ── Initialize browser entries ────────────────
for name in "${BROWSER_NAMES[@]}"; do
	kv_set totals "$name" 0
	kv_set counts "$name" 0
done

ELECTRON_APPS=()

ps_output() {
	ps -eo pid=,rss=,comm= | awk '{printf "%d\t%d\t", $1, $2; for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}'
}

process_line() {
	local pid="$1" rss="$2" comm="$3"
	[[ -z "$pid" || -z "$rss" || -z "$comm" ]] && return 0
	seen_pid "$pid" && return 0

	local matched=false i

	for ((i = 0; i < ${#BROWSER_NAMES[@]}; i++)); do
		if [[ "$comm" == *"${BROWSER_PATTERNS[$i]}"* ]]; then
			kv_inc totals "${BROWSER_NAMES[$i]}" "$rss"
			kv_inc counts "${BROWSER_NAMES[$i]}" 1
			mark_pid "$pid"
			matched=true
			break
		fi
	done
	$matched && return 0

	if [[ "$comm" == /Applications/*.app/* ]]; then
		local app_bundle="${comm#*/Applications/}"
		app_bundle="${app_bundle%%/*}"
		[[ -z "$app_bundle" || "$app_bundle" != *.app ]] && return 0

		local is_browser=false
		for ((i = 0; i < ${#BROWSER_NAMES[@]}; i++)); do
			if [[ "/Applications/$app_bundle/" == *"${BROWSER_PATTERNS[$i]}"* ]]; then
				is_browser=true; break
			fi
		done
		$is_browser && return 0

		local app_name="${app_bundle%.app}"

		if [[ "$comm" == *"Electron Framework"* ]] ||
			[[ "$comm" == *"Helper (Renderer)"* ]] ||
			[[ "$comm" == *"Helper (GPU)"* ]] ||
			[[ "$comm" == *"Helper (Plugin)"* ]] ||
			[[ "$comm" == *"chrome_crashpad_handler"* ]] ||
			[[ "$comm" == *"Helper.app"* ]]; then

			if ! kv_has totals "$app_name"; then
				kv_set totals "$app_name" 0
				kv_set counts "$app_name" 0
				ELECTRON_APPS+=("$app_name")
			fi
			kv_inc totals "$app_name" "$rss"
			kv_inc counts "$app_name" 1
			mark_pid "$pid"
			matched=true
		fi

		if ! $matched && kv_has totals "$app_name"; then
			kv_inc totals "$app_name" "$rss"
			kv_inc counts "$app_name" 1
			mark_pid "$pid"
		fi
	fi
}

while IFS=$'\t' read -r pid rss comm; do
	process_line "$pid" "$rss" "$comm"
done < <(ps_output)

# ── Second pass for Electron main processes ───
if ((${#ELECTRON_APPS[@]} > 0)); then
	while IFS=$'\t' read -r pid rss comm; do
		[[ -z "$pid" || -z "$rss" || -z "$comm" ]] && continue
		seen_pid "$pid" && continue
		if [[ "$comm" == /Applications/*.app/* ]]; then
			app_bundle="${comm#*/Applications/}"
			app_bundle="${app_bundle%%/*}"
			[[ -z "$app_bundle" || "$app_bundle" != *.app ]] && continue
			app_name="${app_bundle%.app}"
			if kv_has totals "$app_name"; then
				kv_inc totals "$app_name" "$rss"
				kv_inc counts "$app_name" 1
				mark_pid "$pid"
			fi
		fi
	done < <(ps_output)
fi

# ── Sort Electron apps by memory desc ─────────
if ((${#ELECTRON_APPS[@]} > 0)); then
	sorted_electron=()
	while IFS= read -r app; do
		sorted_electron+=("$app")
	done < <(
		for app in "${ELECTRON_APPS[@]}"; do
			echo "$(kv_get totals "$app") $app"
		done | sort -rn | sed 's/^[0-9]* //'
	)
	ELECTRON_APPS=("${sorted_electron[@]}")
fi

# ── Format output ─────────────────────────────
human_size() {
	numfmt --to=iec --suffix=B --format="%.1f" $(($1 * 1024)) 2>/dev/null
}

rows=()
browser_total=0
electron_total=0

for name in "${BROWSER_NAMES[@]}"; do
	kb=$(kv_get totals "$name")
	count=$(kv_get counts "$name")
	((kb == 0)) && continue
	browser_total=$((browser_total + kb))
	rows+=("$name|$(human_size "$kb")|$count processes")
done

if ((${#ELECTRON_APPS[@]} > 0)); then
	((${#rows[@]} > 0)) && rows+=("─|─|─")
	for name in "${ELECTRON_APPS[@]}"; do
		kb=$(kv_get totals "$name")
		count=$(kv_get counts "$name")
		((kb == 0)) && continue
		electron_total=$((electron_total + kb))
		rows+=("⚡$name|$(human_size "$kb")|$count processes")
	done
fi

if ((${#rows[@]} == 0)); then
	gum style --foreground 242 "No browsers or Electron apps running."
	exit 0
fi

grand_total=$((browser_total + electron_total))
rows+=("─|─|─")
((browser_total > 0)) && rows+=("Browsers|$(human_size "$browser_total")|")
((electron_total > 0)) && rows+=("⚡Electron|$(human_size "$electron_total")|")
rows+=("TOTAL|$(human_size "$grand_total")|")

printf "%s\n" "App|Memory|Processes" "${rows[@]}" | gum table -s '|' -w 20,10,14 -p
