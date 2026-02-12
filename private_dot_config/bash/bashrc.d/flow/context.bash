#!/usr/bin/env bash
# context.bash — Unified project context switching
# Combines: worknotes, git status, taskwarrior context, pending tasks

WORKNOTES_FILE=".worknotes"

# ── Main project switcher ───────────────────────────────────────────────
workon() {
  local project="$1"

  # No argument? Use fzf to pick from all directories (1-2 levels deep)
  if [[ -z "$project" ]]; then
    project=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 2 -type d \
      ! -path '*/.git' ! -path '*/.git/*' \
      ! -path '*/node_modules' ! -path '*/node_modules/*' \
      ! -path '*/.terraform' ! -path '*/.terraform/*' \
      2>/dev/null \
      | sed "s|^$PROJECTS_DIR/||" \
      | sort \
      | fzf --prompt="Project: " --height=40% --reverse)
    [[ -z "$project" ]] && return 1
  fi

  local dir="${PROJECTS_DIR}/${project}"
  [[ ! -d "$dir" ]] && echo "Project not found: $dir" && return 1

  cd "$dir" || return 1

  # Project ID for taskwarrior (replace / with --)
  local project_id="${project//\//-}"
  export CURRENT_PROJECT="$project_id"
  export TASKFUNC_CURRENT_PROJECT="$project_id"

  echo -e "\033[1;36m━━━ ${project} ━━━\033[0m"
  echo -e "\033[0;90mDirectory: ${dir}\033[0m"
  echo ""

  # ── Worknotes ─────────────────────────────────────────────────────────
  if [[ -f "$WORKNOTES_FILE" ]]; then
    echo -e "\033[1;33m📌 Last notes:\033[0m"
    tail -5 "$WORKNOTES_FILE" | sed 's/^/  /'
    echo ""
  fi

  # ── Git status ────────────────────────────────────────────────────────
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "\033[1;33m📝 Recent commits:\033[0m"
    git log --oneline --no-decorate -5 2>/dev/null | sed 's/^/  /'

    local dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$dirty" -gt 0 ]]; then
      echo -e "\033[1;31m  ⚠️  ${dirty} uncommitted changes\033[0m"
    fi
    echo ""
  fi

  # ── Taskwarrior context ───────────────────────────────────────────────
  if type -P task &>/dev/null; then
    # Create context if it doesn't exist
    if ! command task _context </dev/null 2>/dev/null | grep -qx "$project_id"; then
      command task rc.confirmation=off context define "$project_id" "project:$project_id" </dev/null >/dev/null 2>&1
    fi
    command task context "$project_id" </dev/null >/dev/null 2>&1

    echo -e "\033[1;33m📋 Tasks:\033[0m"
    command task rc.verbose=nothing list </dev/null 2>/dev/null | head -15 | sed 's/^/  /' || echo "  No pending tasks"
    echo ""
  fi

  # ── Environment ───────────────────────────────────────────────────────
  # Restore tmux layout if saved
  [[ -f ".tmux-layout" ]] && [[ -n "$TMUX" ]] && tmux source-file ".tmux-layout" 2>/dev/null

  # Direnv
  [[ -f ".envrc" ]] && command -v direnv &>/dev/null && direnv allow . 2>/dev/null

  # Hints
  echo -e "\033[0;90mwn <note> | tl | tstart | q <thought>\033[0m"
}

# Alias for muscle memory
alias p='workon'

# ── Quick peek (cd only, no context) ────────────────────────────────────
pp() {
  local project
  project=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 2 -type d \
    ! -path '*/.git' ! -path '*/.git/*' \
    2>/dev/null \
    | sed "s|^$PROJECTS_DIR/||" \
    | sort \
    | fzf --prompt="Peek: " --height=40% --reverse)
  [[ -n "$project" ]] && cd "${PROJECTS_DIR}/${project}" || return 1
}

# ── Clear context ───────────────────────────────────────────────────────
poff() {
  if type -P task &>/dev/null; then
    command task context none >/dev/null 2>&1
  fi
  unset CURRENT_PROJECT TASKFUNC_CURRENT_PROJECT
  echo "Project context cleared."
}

# ── Worknotes ───────────────────────────────────────────────────────────

# Leave a note for future-you
wn() {
  if [[ -z "$*" ]]; then
    echo "Usage: wn <note for future you>"
    return 1
  fi
  echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$WORKNOTES_FILE"
  echo "📌 noted"
}

# Show recent notes across ALL projects
wn-all() {
  local days="${1:-1}"
  echo -e "\033[1;36m━━━ Notes from last ${days} day(s) ━━━\033[0m"
  find "$PROJECTS_DIR" -name "$WORKNOTES_FILE" -mtime "-${days}" -exec sh -c '
    proj=$(dirname "{}" | sed "s|'"$PROJECTS_DIR"'/||")
    echo "\033[1;33m[$proj]\033[0m"
    tail -5 "{}" | sed "s/^/  /"
    echo ""
  ' \;
}

# ── Tmux layout ─────────────────────────────────────────────────────────
worksave() {
  if [[ -z "$TMUX" ]]; then
    echo "Not in tmux"
    return 1
  fi
  tmux list-windows -F '#{window_layout}' > ".tmux-layout"
  echo "tmux layout saved"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "project" "workon" "Switch project (fzf): worknotes + git + tasks"
_reg "project" "workon <name>" "Switch to specific project"
_reg "project" "p" "Alias for workon"
_reg "project" "pp" "Peek — cd to project without context"
_reg "project" "poff" "Clear project context"
_reg "project" "wn <text>" "Leave note for future you"
_reg "project" "wn-all [days]" "Show notes from all projects"
_reg "project" "worksave" "Save current tmux layout for project"
