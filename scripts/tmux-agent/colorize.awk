#!/usr/bin/env awk -f
# colorize.awk — read TSV from extract.sh, emit padded + ANSI-colored TSV.
#
# Input columns (tab-separated):
#   1 pane_id   2 agent   3 state   4 dirname   5 tmux_session   6 title   7 mru_key
#
# Output columns (tab-separated, same order):
#   pane_id | colored-padded agent | colored-padded state |
#   colored-padded dirname | colored-padded tmux_session |
#   colored title | mru_key
#
# Rules:
#   - Padding is applied to plain text BEFORE ANSI wrapping (byte-safe).
#   - Palette selected via env var THEME (dark|light); defaults to dark.
#   - Title is NOT padded (last visible column, allow it to run to eol).
#   - If env var HEADER_FILE is set, a plain-text (colored) header string is
#     written to that path, padded to the same column widths as the data.
#     The header is joined with two spaces (matching fzf --with-nth spacing)
#     so it aligns visually with `--with-nth='{2}  {3}  {4}  {5}  {6}'`.

BEGIN {
	FS = "\t"; OFS = "\t"

	# Pick palette based on THEME env var
	theme = ENVIRON["THEME"]
	if (theme == "") theme = "dark"

	if (theme == "light") {
		# catppuccin latte
		C_mauve    = rgb(136,  57, 239)
		C_red      = rgb(210,  15,  57)
		C_peach    = rgb(254, 100,  11)
		C_green    = rgb( 64, 160,  43)
		C_yellow   = rgb(223, 142,  29)
		C_blue     = rgb( 30, 102, 245)
		C_sapphire = rgb( 32, 159, 181)
		C_teal     = rgb( 23, 146, 153)
		C_text     = rgb( 76,  79, 105)
		C_subtext1 = rgb( 92,  95, 119)
		C_overlay0 = rgb(156, 160, 176)
	} else {
		# catppuccin mocha
		C_mauve    = rgb(203, 166, 247)
		C_red      = rgb(243, 139, 168)
		C_peach    = rgb(250, 179, 135)
		C_green    = rgb(166, 227, 161)
		C_yellow   = rgb(249, 226, 175)
		C_blue     = rgb(137, 180, 250)
		C_sapphire = rgb(116, 199, 236)
		C_teal     = rgb(148, 226, 213)
		C_text     = rgb(205, 214, 244)
		C_subtext1 = rgb(186, 194, 222)
		C_overlay0 = rgb(108, 112, 134)
	}
	RESET = "\033[0m"

	# Header labels
	H_AGENT = "AGENT"
	H_STATE = "STATUS"
	H_DIR   = "DIR"
	H_SESS  = "TMUX SESSION"
	H_TITLE = "TITLE"

	n = 0
	max_agent = length(H_AGENT)
	max_state = length(H_STATE)
	max_dir   = length(H_DIR)
	max_sess  = length(H_SESS)

	header_file = ENVIRON["HEADER_FILE"]
}

function rgb(r, g, b,   s) {
	s = sprintf("\033[38;2;%d;%d;%dm", r, g, b)
	return s
}

function color_for_state(s) {
	if (s == "BUSY") return C_red
	if (s == "IDLE") return C_green
	if (s == "WAIT") return C_yellow
	if (s == "DONE") return C_blue
	if (s == "DEAD") return C_peach
	return C_overlay0
}

function pad(str, width,   n) {
	n = width - length(str)
	if (n <= 0) return str
	return str sprintf("%*s", n, "")
}

{
	n++
	pane[n]  = $1
	agent[n] = $2
	state[n] = $3
	dir[n]   = $4
	sess[n]  = $5
	title[n] = $6
	mru[n]   = $7

	if (length($2) > max_agent) max_agent = length($2)
	if (length($3) > max_state) max_state = length($3)
	if (length($4) > max_dir)   max_dir   = length($4)
	if (length($5) > max_sess)  max_sess  = length($5)
}

END {
	# Emit header (padded + colored) to HEADER_FILE if requested.
	if (header_file != "") {
		h = C_overlay0 pad(H_AGENT, max_agent) RESET "  " \
		    C_overlay0 pad(H_STATE, max_state) RESET "  " \
		    C_overlay0 pad(H_DIR,   max_dir)   RESET "  " \
		    C_overlay0 pad(H_SESS,  max_sess)  RESET "  " \
		    C_overlay0 H_TITLE                 RESET
		print h > header_file
	}

	for (i = 1; i <= n; i++) {
		# Agent color: mauve if current pane marker present, else text
		if (agent[i] ~ /^\*/) c_agent = C_mauve
		else                  c_agent = C_text

		a = c_agent    pad(agent[i], max_agent) RESET
		s = color_for_state(state[i]) pad(state[i], max_state) RESET
		d = C_teal     pad(dir[i],   max_dir)   RESET
		x = C_sapphire pad(sess[i],  max_sess)  RESET
		t = C_subtext1 title[i]                 RESET

		printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", pane[i], a, s, d, x, t, mru[i]
	}
}
