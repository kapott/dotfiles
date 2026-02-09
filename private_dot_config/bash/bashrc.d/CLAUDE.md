# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Bash shell configuration directory (`~/.config/bash/bashrc.d/`) with modular scripts organized by category. Files are sourced alphabetically, then `40-loader.bash` sources category subdirectories.

## Structure

```
bashrc.d/
├── 00-env.bash           # Environment: XDG, EDITOR, PROJECTS_DIR, THOUGHTS_DIR
├── 01-prompt.bash        # PS1 with git branch, window title
├── 02-globals.bash       # PATH, mise, homebrew
├── 10-aliases.bash       # Basic shell aliases
├── 20-functions.bash     # Utility functions (SSL, process helpers)
├── 21-update.bash        # Cross-distro `upg` command
├── 30-settings.bash      # Shell options (shopt), fzf config
├── 40-loader.bash        # Sources subdirectories in order
├── common/
│   ├── registry.bash     # Command registry (_reg, h, hh)
│   └── notify.bash       # Cross-platform notifications
├── flow/
│   ├── capture.bash      # Thought capture (q, qt, qq, qd, qs)
│   ├── context.bash      # Project switching (workon/p, wn, poff)
│   ├── guardrails.bash   # kubectl safety wrapper (k)
│   ├── prompt-k8s.bash   # k8s prompt, starship config
│   └── timers.bash       # Flow timers (flowstart, goedemorgen, eod)
├── time/
│   ├── tasks.bash        # Taskwarrior (t, ta, tl, tstart, tdone)
│   ├── timewarrior.bash  # Timewarrior (tw, twday, twlog)
│   └── reviews.bash      # Daily/weekly reviews
├── nav/
│   ├── fzf.bash          # fzf navigation (fe, fd, fgr)
│   ├── git.bash          # git shortcuts (gs, gd, gl)
│   ├── k8s.bash          # kubectl shortcuts (kgp, klog, ksh)
│   └── infra.bash        # helm, terraform, tmux
├── term.bash
└── zoxide.bash
```

## Loading Order

1. Numbered files (00-39) source alphabetically
2. `40-loader.bash` sources subdirectories:
   - `common/` first (registry must load before others call `_reg`)
   - `flow/`
   - `time/`
   - `nav/`

## Key Patterns

### Command Registry
All functions in subdirectories register via `_reg "category" "command" "description"`.
- `h` - fzf command browser with preview
- `hh` - flat greppable list

### Project Switching (`workon` / `p`)
Unified project switcher in `flow/context.bash`. One command does everything:
- fzf picker for projects (1-2 levels deep in `$PROJECTS_DIR`)
- cd to project directory
- Sets `$CURRENT_PROJECT` and taskwarrior context
- Shows last worknotes (`.worknotes` file)
- Shows recent git commits and uncommitted changes
- Shows pending taskwarrior tasks for this project
- Restores tmux layout if `.tmux-layout` exists
- Activates direnv if `.envrc` present

Related commands:
- `pp` - quick cd without context setting
- `poff` - clear project context
- `wn <note>` - leave note for future you
- `tadd <task>` - add task to current project

### Guardrails
`k` wraps kubectl with prod safety checks (confirm destructive ops).

### Time Tracking
Taskwarrior + Timewarrior integration:
- `t` = task, `tstart`/`tstop`/`tdone` for task lifecycle
- `tw` = timew, `twlog` for retroactive time entry
- Reviews: `weekstart`, `dayreview`, `dayend`

### Thought Capture
Quick capture to `$THOUGHTS_DIR/inbox.md`:
- `q <text>` - capture with project context
- `qt <text>` - capture as TODO
- `qd <num>` - mark done
- `qs` - stats

## Key Aliases

| Alias | Command | Notes |
|-------|---------|-------|
| `t` | task | taskwarrior |
| `tx` | tmux new -AsBOFH | quick tmux attach |
| `v` | vim | editor |
| `vt` | vit | taskwarrior TUI |
| `k` | kubectl wrapper | with prod guardrails |
| `h` | command browser | fzf |
| `p` | workon | project switcher |

## Dependencies

Required: `fzf`, `jq`
Time tracking: `taskwarrior`, `timewarrior`
K8s: `kubectl`, optionally `argocd`, `vault`
Optional: `starship`, `lazygit`, `zoxide`, `vit`, `direnv`

## Conventions

- Internal functions prefixed with `_`
- All files use `.bash` extension
- `$CURRENT_PROJECT` is the canonical project identifier (set by `workon`)
