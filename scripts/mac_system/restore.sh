#!/usr/bin/env bash
# restore.sh — Restore macOS preferences from backup + curated modules
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/checks.sh"
source "$SCRIPT_DIR/lib/defaults.sh"

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

# --- Parse Args ---
DRY_RUN=0
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	esac
done
export DRY_RUN

# --- Main ---
log_header "macOS Restore" "$(macos_version) • $(hostname)"

require_cmd gum python3 plutil

MAJOR=$(macos_major)
if [[ "$MAJOR" -lt 15 ]]; then
	log_warn "Untested macOS version: $(macos_version) — proceed with caution"
fi

if [[ "$DRY_RUN" == "1" ]]; then
	log_warn "DRY RUN mode — no changes will be written"
fi

BACKUP_DIR="$SCRIPT_DIR/backups"

# --- Phase 1: Import full backup plists ---
log_info "Phase 1: Importing backup plists..."
for domain in "${DOMAINS[@]}"; do
	defaults_import_domain "$domain" "$BACKUP_DIR/${domain}.plist"
done

# --- Phase 2: Run curated modules ---
log_info "Phase 2: Applying curated modules..."
for module in "$SCRIPT_DIR"/modules/[0-9]*.sh; do
	if [[ -f "$module" ]]; then
		log_info "Running: $(basename "$module")"
		source "$module"
	fi
done

# --- Restart affected services ---
if [[ "$DRY_RUN" == "0" ]]; then
	log_info "Restarting Dock, Finder, SystemUIServer..."
	killall Dock Finder SystemUIServer 2>/dev/null || true
fi

# --- Summary ---
defaults_summary
log_info "Restore complete: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
