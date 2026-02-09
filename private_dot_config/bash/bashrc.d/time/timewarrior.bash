#!/usr/bin/env bash
# timewarrior.bash — Timewarrior functions and aliases

# ── Dependency check ────────────────────────────────────────────────────
command -v timew >/dev/null 2>&1 || {
    echo "time/timewarrior.bash: timew not found" >&2
}

# ── Aliases ─────────────────────────────────────────────────────────────
alias tw='timew'
alias tws='timew summary'
alias twst='timew start'
alias twsp='timew stop'
alias twday='timew summary :day'
alias twweek='timew summary :week'
alias twmonth='timew summary :month'
alias twtags='timew tags'
alias twids='timew summary :ids'

# ── Functions ───────────────────────────────────────────────────────────

# Show current tracking status
twcurrent() {
    echo "=== CURRENT TIME TRACKING ==="
    timew
    echo ""
    echo "=== ACTIVE TASK ==="
    task +ACTIVE 2>/dev/null || echo "No active task"
}

# Quick time entry for past work
# Usage: twlog <duration> <tags...>
# Example: twlog 2h coding projectX
twlog() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: twlog <duration> <description/tags...>"
        echo "Example: twlog 2h coding project"
        return 1
    fi
    local duration="$1"
    shift
    timew track "${duration}ago" - now "$@"
}

# Adjust start time of current tracking
# Usage: twback <minutes>
twback() {
    local minutes="${1:-30}"
    timew modify start - "${minutes}min"
    echo "Adjusted start time by -${minutes} minutes"
}

# Start tracking a project directly (without task)
# Usage: twproj <project_name>
twproj() {
    if [[ -z "$1" ]]; then
        local project
        project=$(task _projects 2>/dev/null | fzf --prompt="Track project: " --height=40% --reverse)
        if [[ -n "$project" ]]; then
            timew start "$project"
            echo "Tracking: $project"
        fi
    else
        timew start "$@"
        echo "Tracking: $*"
    fi
}

# Show time summary for a specific project
twsumproj() {
    local project="$1"
    if [[ -z "$project" ]]; then
        project=$(task _projects 2>/dev/null | fzf --prompt="Select project: " --height=40% --reverse)
    fi
    if [[ -n "$project" ]]; then
        echo "=== Time for project: $project ==="
        timew summary :week "$project"
    fi
}

# ── Completions (bash) ──────────────────────────────────────────────────
if [[ -n "$BASH_VERSION" ]]; then
    _timew_projects() {
        local projects=$(task _projects 2>/dev/null)
        COMPREPLY=($(compgen -W "$projects" -- "${COMP_WORDS[COMP_CWORD]}"))
    }
    complete -F _timew_projects twproj twsumproj
fi

# ── Registry ─────────────────────────────────────────────────────────────
_reg "timew" "tw" "timew (timewarrior)"
_reg "timew" "tws" "timew summary"
_reg "timew" "twst" "timew start"
_reg "timew" "twsp" "timew stop"
_reg "timew" "twday" "timew summary :day"
_reg "timew" "twweek" "timew summary :week"
_reg "timew" "twmonth" "timew summary :month"
_reg "timew" "twtags" "timew tags"
_reg "timew" "twids" "timew summary :ids"
_reg "timew" "twcurrent" "Show current tracking + active task"
_reg "timew" "twlog <dur> <tags>" "Log past work (e.g., twlog 2h coding)"
_reg "timew" "twback [min]" "Adjust start time by -N minutes"
_reg "timew" "twproj [proj]" "Start tracking project (fzf if no arg)"
_reg "timew" "twsumproj [proj]" "Time summary for project"
