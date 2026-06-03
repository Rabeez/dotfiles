#!/usr/bin/env bash
# backup.sh — Full export of current macOS preferences for all managed domains
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/checks.sh"

# --- Managed Domains ---
DOMAINS=(
	NSGlobalDomain
	com.apple.dock
	com.apple.finder
	com.apple.AppleMultitouchTrackpad
	com.apple.driver.AppleBluetoothMultitouch.trackpad
	com.apple.universalaccess
	com.apple.screencapture
	com.apple.controlcenter
	com.apple.menuextra.clock
	com.apple.HIToolbox
	com.apple.loginwindow
	com.apple.ActivityMonitor
	com.apple.CloudSubscriptionFeatures.optIn
)

# --- Main ---
log_header "macOS Backup" "$(macos_version) • $(hostname)"

require_cmd gum python3

BACKUP_DIR="$SCRIPT_DIR/backups"
PLISTS_DIR="$SCRIPT_DIR/plists"
SORT_PLIST="$SCRIPT_DIR/lib/sort_plist.py"

mkdir -p "$BACKUP_DIR" "$PLISTS_DIR"

count=0
for domain in "${DOMAINS[@]}"; do
	if defaults export "$domain" - 2>/dev/null | python3 "$SORT_PLIST" >"$BACKUP_DIR/${domain}.plist" 2>/dev/null; then
		log_info "Exported: $domain"
		((count++))
	else
		log_warn "No defaults found for: $domain (skipping)"
		rm -f "$BACKUP_DIR/${domain}.plist"
	fi
done

# Extract dock persistent-apps array
if /usr/libexec/PlistBuddy -c "Print :persistent-apps" ~/Library/Preferences/com.apple.dock.plist &>/dev/null; then
	defaults export com.apple.dock - | python3 -c "
import plistlib, sys
data = plistlib.loads(sys.stdin.buffer.read())
out = {'persistent-apps': data.get('persistent-apps', [])}
plistlib.dump(out, sys.stdout.buffer, fmt=plistlib.FMT_XML, sort_keys=True)
" >"$PLISTS_DIR/dock-apps.plist"
	log_info "Exported: dock persistent-apps"
fi

log_info "Backup complete: $count domains exported"
log_info "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
