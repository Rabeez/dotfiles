#!/usr/bin/env bash
# lib/defaults.sh — Idempotent defaults helpers (set, import, verify)

STATS_APPLIED=0
STATS_SKIPPED=0
STATS_FAILED=0

# Idempotent scalar setter
# Usage: defaults_set "com.apple.dock" "autohide" "-bool" "true"
defaults_set() {
	local domain="$1" key="$2" type="$3" value="$4"
	local current
	current=$(defaults read "$domain" "$key" 2>/dev/null) || current="__UNSET__"

	# Normalize for comparison
	local expected="$value"
	[[ "$type" == "-bool" && "$value" == "true" ]] && expected="1"
	[[ "$type" == "-bool" && "$value" == "false" ]] && expected="0"

	if [[ "$current" == "$expected" ]]; then
		log_debug "Already set: $domain $key = $value"
		((STATS_SKIPPED++))
		return 0
	fi

	if [[ "${DRY_RUN:-0}" == "1" ]]; then
		log_info "[DRY RUN] Would set: $domain $key $type $value (current: $current)"
		return 0
	fi

	defaults write "$domain" "$key" "$type" "$value"

	# Verify
	local after
	after=$(defaults read "$domain" "$key" 2>/dev/null) || after="__FAILED__"
	if [[ "$after" == "$expected" ]]; then
		log_info "Set: $domain $key = $value"
		((STATS_APPLIED++))
	else
		log_error "FAILED: $domain $key (expected=$expected, got=$after)"
		((STATS_FAILED++))
		return 1
	fi
}

# Write a specific key from a plist file into a domain
# Usage: defaults_write_key "com.apple.dock" "persistent-apps" "/path/to/dock-apps.plist"
defaults_write_key() {
	local domain="$1" key="$2" plist="$3"

	if [[ ! -f "$plist" ]]; then
		log_error "Plist not found: $plist"
		return 1
	fi

	if [[ "${DRY_RUN:-0}" == "1" ]]; then
		log_info "[DRY RUN] Would write key: $domain $key from $plist"
		return 0
	fi

	# Delete existing key, then merge from plist
	defaults delete "$domain" "$key" 2>/dev/null || true
	/usr/libexec/PlistBuddy -c "Merge '$plist' '$key'" \
		~/Library/Preferences/"$domain".plist 2>/dev/null ||
		defaults import "$domain" "$plist"
	log_info "Wrote key: $domain $key from $plist"
	((STATS_APPLIED++))
}

# Import a full domain backup plist
# Usage: defaults_import_domain "com.apple.dock" "/path/to/backup.plist"
defaults_import_domain() {
	local domain="$1" plist="$2"

	if [[ ! -f "$plist" ]]; then
		log_warn "Backup not found for $domain: $plist (skipping)"
		return 0
	fi

	if [[ "${DRY_RUN:-0}" == "1" ]]; then
		log_info "[DRY RUN] Would import domain: $domain from $plist"
		return 0
	fi

	defaults import "$domain" "$plist"
	log_info "Imported domain: $domain from $plist"
}

# Print summary stats
defaults_summary() {
	log_info "Summary: $STATS_APPLIED applied, $STATS_SKIPPED already correct, $STATS_FAILED failed"
}
