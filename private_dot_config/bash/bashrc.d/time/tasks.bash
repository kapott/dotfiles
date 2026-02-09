#!/usr/bin/env bash
# tasks.bash — Taskwarrior aliases and functions

# ── Configuration ───────────────────────────────────────────────────────
TASKFUNC_PROJECTS_DIR="${TASKFUNC_PROJECTS_DIR:-$PROJECTS_DIR}"
TASKFUNC_CURRENT_PROJECT=""
TASKFUNC_VERBOSE="${TASKFUNC_VERBOSE:-new-id}"

# Wrapper to suppress verbose taskwarrior output
task() {
    command task rc.verbose="$TASKFUNC_VERBOSE" "$@"
}

# ── Dependency check ────────────────────────────────────────────────────
_taskfunc_check_deps() {
    local missing=()
    command -v task >/dev/null 2>&1 || missing+=("taskwarrior")
    command -v fzf >/dev/null 2>&1 || missing+=("fzf")
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "time/tasks.bash: missing: ${missing[*]}" >&2
    fi
}
_taskfunc_check_deps

# ── Basic aliases ───────────────────────────────────────────────────────
alias t='task'
alias ta='task add'
alias tl='task list'
alias tn='task next'
alias te='task edit'
alias ti='task info'

# Task views
alias tall='task all'
alias tcomp='task completed'
alias tblock='task blocked'
alias tunblock='task unblocked'
alias tover='task overdue'
alias tready='task ready'
alias twait='task waiting'

# Task actions
alias tmod='task modify'
alias tdel='task delete'
alias tundo='task undo'

# Task filters
alias turgent='task +urgent'
alias tnxt='task +next'
alias tinbox='task +inbox'
alias ttoday='task due:today'
alias tweek='task due.before:sunday'

# Context
alias tctx='task context'
alias tctxs='task context show'
alias tproj='task projects'

# Vit (use vt to avoid conflict with v=vim)
alias vt='vit'

# ── Functions ───────────────────────────────────────────────────────────

# Clear project scope and context (use 'poff' from flow/context.bash)
tctxn() {
    task context none >/dev/null 2>&1
    unset CURRENT_PROJECT TASKFUNC_CURRENT_PROJECT
    echo "Project scope cleared. Showing all tasks."
}

# List tasks for current project scope
tpl() {
    if [[ -n "$CURRENT_PROJECT" ]]; then
        task project:"$CURRENT_PROJECT" list
    else
        echo "No project scope set. Use 'workon' to select a project."
    fi
}

# Quick add task to current project (or inbox if no project)
tadd() {
    if [[ -z "$*" ]]; then
        echo "Usage: tadd <task description>"
        return 1
    fi
    if [[ -n "$CURRENT_PROJECT" ]]; then
        task add "$@" project:"$CURRENT_PROJECT"
        echo "Added to project: $CURRENT_PROJECT"
    else
        task add "$@" +inbox
        echo "Added to inbox (use 'workon' to select a project)"
    fi
}

# Start a task with time tracking (fzf if no ID)
tstart() {
    local task_id="$1"
    if [[ -z "$task_id" ]]; then
        task_id=$(task +PENDING export | jq -r '.[] | "\(.id)\t\(.description)"' | \
            fzf --prompt="Start task: " --height=40% --reverse | cut -f1)
    fi
    [[ -n "$task_id" ]] && task "$task_id" start && echo "Started task $task_id"
}

# Stop current task and time tracking
tstop() {
    local active_id
    active_id=$(task +ACTIVE ids 2>/dev/null)
    if [[ -n "$active_id" ]]; then
        task "$active_id" stop
        echo "Stopped task $active_id"
    else
        timew stop 2>/dev/null
        echo "Stopped time tracking"
    fi
}

# Complete a task (fzf if no ID)
tdone() {
    local task_id="$1"
    if [[ -z "$task_id" ]]; then
        task_id=$(task +PENDING export | jq -r '.[] | "\(.id)\t\(.description)"' | \
            fzf --prompt="Complete task: " --height=40% --reverse | cut -f1)
    fi
    [[ -n "$task_id" ]] && task "$task_id" done
}

# Interactive task modification with fzf
tmodf() {
    local task_id
    task_id=$(task +PENDING export | jq -r '.[] | "\(.id)\t\(.project // "none")\t\(.description)"' | \
        column -t -s $'\t' | \
        fzf --prompt="Modify task: " --height=40% --reverse | awk '{print $1}')

    if [[ -n "$task_id" ]]; then
        echo "Task $task_id selected. Enter modifications:"
        echo "(e.g., +tag, -tag, project:name, due:tomorrow, priority:H)"
        read -r mods
        [[ -n "$mods" ]] && task "$task_id" modify $mods
    fi
}

# Interactive task deletion with fzf
tdelf() {
    local task_id
    task_id=$(task +PENDING export | jq -r '.[] | "\(.id)\t\(.description)"' | \
        fzf --prompt="Delete task: " --height=40% --reverse | cut -f1)
    [[ -n "$task_id" ]] && task "$task_id" delete
}

# Add task with interactive project selection
taddp() {
    if [[ -z "$*" ]]; then
        echo "Usage: taddp <task description>"
        return 1
    fi
    local project
    project=$(task _projects | fzf --prompt="Select project: " --height=40% --reverse)
    if [[ -n "$project" ]]; then
        task add "$@" project:"$project"
    else
        task add "$@"
    fi
}

# Backup tasks
tbackup() {
    local backup_dir="${1:-$HOME/.task-backups}"
    local backup_file="$backup_dir/task-backup-$(date +%Y%m%d-%H%M%S).json"
    mkdir -p "$backup_dir"
    task export > "$backup_file"
    echo "Backed up to: $backup_file"
}

# Sync tasks
tsync() { task sync; }

# ── Completions (bash) ──────────────────────────────────────────────────
if [[ -n "$BASH_VERSION" ]]; then
    _taskfunc_task_ids() {
        local ids=$(task +PENDING _ids 2>/dev/null)
        COMPREPLY=($(compgen -W "$ids" -- "${COMP_WORDS[COMP_CWORD]}"))
    }
    _taskfunc_projects() {
        local projects=$(task _projects 2>/dev/null)
        COMPREPLY=($(compgen -W "$projects" -- "${COMP_WORDS[COMP_CWORD]}"))
    }
    complete -F _taskfunc_task_ids tstart tdone tmodf tdelf
    complete -F _taskfunc_projects taddp
fi

# ── Registry ─────────────────────────────────────────────────────────────
_reg "task" "t" "task (taskwarrior)"
_reg "task" "ta" "task add"
_reg "task" "tl" "task list"
_reg "task" "tn" "task next"
_reg "task" "te" "task edit"
_reg "task" "ti" "task info"
_reg "task" "tall" "task all"
_reg "task" "tcomp" "task completed"
_reg "task" "tblock" "task blocked"
_reg "task" "tover" "task overdue"
_reg "task" "tready" "task ready"
_reg "task" "twait" "task waiting"
_reg "task" "tmod" "task modify"
_reg "task" "tdel" "task delete"
_reg "task" "tundo" "task undo"
_reg "task" "turgent" "task +urgent"
_reg "task" "tinbox" "task +inbox"
_reg "task" "ttoday" "task due:today"
_reg "task" "tweek" "task due.before:sunday"
_reg "task" "vt" "vit (taskwarrior TUI)"
_reg "task" "tpl" "List tasks for current project"
_reg "task" "tadd <desc>" "Add task to current project"
_reg "task" "taddp <desc>" "Add task with project picker"
_reg "task" "tstart [id]" "Start task + time tracking (fzf if no id)"
_reg "task" "tstop" "Stop current task + time tracking"
_reg "task" "tdone [id]" "Complete task (fzf if no id)"
_reg "task" "tmodf" "Modify task (fzf)"
_reg "task" "tdelf" "Delete task (fzf)"
_reg "task" "tctxn" "Clear context (show all tasks)"
_reg "task" "tbackup" "Backup tasks to JSON"
_reg "task" "tsync" "Sync tasks"
