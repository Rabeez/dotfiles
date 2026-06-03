#!/usr/bin/env bash
# 09-keyboard.sh — Input sources, text replacements
# These are typically restored via the full backup import (Phase 1).
# This module exists as a placeholder for any explicit overrides.

# Input sources are stored in com.apple.HIToolbox AppleEnabledInputSources
# and are complex array structures best handled by the plist import.

log_debug "Keyboard settings restored via backup import (com.apple.HIToolbox)"
