import json
import os
import subprocess

from kitty.boss import get_boss
from kitty.tab_bar import (
    as_rgb,
    draw_tab_with_powerline,
)

# Catppuccin Mocha colors
BLUE = as_rgb(0x89B4FA)
GREEN = as_rgb(0xA6E3A1)
RED = as_rgb(0xF38BA8)
YELLOW = as_rgb(0xF9E2AF)
CYAN = as_rgb(0x94E2D5)
WHITE = as_rgb(0xCDD6F4)
SUBTEXT = as_rgb(0xA6ADC8)


def _get_gitmux(cwd):
    if not cwd:
        return None
    try:
        r = subprocess.run(
            ["/opt/homebrew/bin/gitmux", "-dbg"],
            capture_output=True,
            text=True,
            timeout=2,
            cwd=cwd,
        )
        if r.returncode == 0:
            return json.loads(r.stdout)
    except Exception:
        pass
    return None


def draw_tab(
    draw_data,
    screen,
    tab,
    before,
    max_tab_length,
    index,
    is_last,
    extra_data,
):
    end = draw_tab_with_powerline(
        draw_data,
        screen,
        tab,
        before,
        max_tab_length,
        index,
        is_last,
        extra_data,
    )

    if is_last:
        try:
            boss = get_boss()
            at = boss.active_tab
            cwd = at.active_window.cwd_of_child if at and at.active_window else ""
        except Exception:
            cwd = ""

        dirname = os.path.basename(cwd) if cwd else ""
        gitmux = _get_gitmux(cwd)

        # Build right-side cells: list of (color, text)
        cells = []

        if gitmux:
            branch = gitmux.get("LocalBranch", "")
            remote = gitmux.get("RemoteBranch", "")
            is_clean = gitmux.get("IsClean", False)
            modified = gitmux.get("NumModified", 0)
            staged = gitmux.get("NumStaged", 0)
            untracked = gitmux.get("NumUntracked", 0)
            ahead = gitmux.get("AheadCount", 0)
            behind = gitmux.get("BehindCount", 0)

            # Dirname first
            if dirname:
                cells.append((BLUE, f" {dirname} "))

            # Branch
            if branch:
                cells.append((RED, "󰊢 "))
                cells.append((WHITE, f"{branch}"))
            # Remote
            # if remote:
            #     cells.append((CYAN, f" {remote}"))

            # Divergence
            if ahead > 0:
                cells.append((GREEN, f" \u2191{ahead}"))
            if behind > 0:
                cells.append((RED, f" \u2193{behind}"))

            # Status
            cells.append((SUBTEXT, " - "))
            if is_clean:
                cells.append((GREEN, "\u2714"))
            else:
                parts = []
                if modified > 0:
                    parts.append((YELLOW, f"~{modified}"))
                if staged > 0:
                    parts.append((GREEN, f"+{staged}"))
                if untracked > 0:
                    parts.append((RED, f"?{untracked}"))
                for i, (color, text) in enumerate(parts):
                    if i > 0:
                        cells.append((SUBTEXT, " "))
                    cells.append((color, text))
        # Non-git dir: just dirname
        elif dirname:
            cells.append((BLUE, f" {dirname}"))

        if cells:
            right_text = "".join(text for _, text in cells) + " "
            padding = screen.columns - screen.cursor.x - len(right_text)
            if padding > 0:
                screen.cursor.fg = 0
                screen.cursor.bg = 0
                screen.draw(" " * padding)
                for color, text in cells:
                    screen.cursor.fg = color
                    screen.cursor.bg = 0
                    screen.draw(text)
                screen.draw(" ")

    return end
