#!/usr/bin/env bash
# 08-security.sh — Guest accounts off, Apple Intelligence off, login window

# Disable Apple Intelligence
defaults_set com.apple.CloudSubscriptionFeatures.optIn "545129924" "-bool" "false"

# Disable guest account (requires admin)
if [[ "${DRY_RUN:-0}" == "1" ]]; then
	log_info "[DRY RUN] Would disable guest account"
else
	sudo sysadminctl -guestAccount off 2>/dev/null || log_warn "Could not disable guest account (needs sudo)"
fi

# Login window: show username/password fields (not user list)
defaults_set com.apple.loginwindow SHOWFULLNAME "-bool" "true"
