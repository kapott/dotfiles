#!/usr/bin/env bash
# flow.sh — Flow state management and physical self-care reminders
# Solves: hyperfocus without breaks, forgetting to eat/drink, cold-start mornings
# Depends: notify.sh (source it first)

THOUGHTS_DIR="${THOUGHTS_DIR:-$HOME/thoughts}"
_FLOW_PID_FILE="/tmp/.flow-timer-$$"

# ── Flow session ─────────────────────────────────────────────────────────

flowstart() {
  local duration="${1:-90}" # default 90 min deep work block
  echo -e "\033[1;36m🧠 Flow gestart $(date '+%H:%M') — ${duration} min block\033[0m"
  echo -e "\033[1;36m   Project: ${CURRENT_PROJECT:-?}\033[0m"

  # Kill any existing flow timer
  flowstop 2>/dev/null

  (
    # Water reminder at 25 min
    sleep $((25 * 60)) && _notify "💧 25 min" "Water drinken" &

    # Stretch at 45 min
    sleep $((45 * 60)) && _notify "🧘 45 min" "Stretch even — nek, schouders, polsen" &

    # Serious break at configured duration
    sleep $((duration * 60)) && _notify_critical "⏰ ${duration} min" "Sta op. Loop. Eet iets." &

    # Store PIDs for cleanup
    wait
  ) &
  echo $! > "$_FLOW_PID_FILE"
  disown
}

flowstop() {
  if [[ -f "$_FLOW_PID_FILE" ]]; then
    local pid=$(cat "$_FLOW_PID_FILE")
    kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null
    rm -f "$_FLOW_PID_FILE"
    echo "⏹️  Flow timer gestopt"
  fi
}

# Quick pomodoro — 25 min focus, 5 min break
pomo() {
  local label="${*:-focus}"
  echo -e "\033[1;36m🍅 Pomodoro: ${label} (25 min)\033[0m"
  (
    sleep $((25 * 60)) && _notify_critical "🍅 Pomodoro klaar" "5 min pauze — ${label}"
  ) &
  disown
}

# ── Morning startup ritual ───────────────────────────────────────────────

goedemorgen() {
  echo -e "\033[1;36m"
  echo "  ☀️  Goedemorgen — $(date '+%A %d %B %Y')"
  echo -e "\033[0m"

  # Yesterday's EOD notes
  local yesterday_eod=$(grep -l "## EOD" "${THOUGHTS_DIR}/daily.md" 2>/dev/null)
  if [[ -n "$yesterday_eod" ]]; then
    echo -e "\033[1;33m📋 Gisteren eindigde je met:\033[0m"
    tail -6 "${THOUGHTS_DIR}/daily.md" 2>/dev/null | sed 's/^/  /'
    echo ""
  fi

  # Inbox items
  local inbox_count=0
  [[ -f "${THOUGHTS_DIR}/inbox.md" ]] && inbox_count=$(wc -l < "${THOUGHTS_DIR}/inbox.md" | tr -d ' ')
  if [[ "$inbox_count" -gt 0 ]]; then
    echo -e "\033[1;33m💭 ${inbox_count} items in thought inbox\033[0m"
    echo "   (qi om te bekijken)"
    echo ""
  fi

  # Calendar (if icalBuddy available on macOS, or similar)
  if command -v icalBuddy &>/dev/null; then
    echo -e "\033[1;33m📅 Vandaag:\033[0m"
    icalBuddy -n -nc eventsToday 2>/dev/null | sed 's/^/  /'
    echo ""
  fi

  # Cluster health check shortcut
  echo -e "\033[0;37m   kstatus  — check cluster health\033[0m"
  echo -e "\033[0;37m   workon   — pick a project\033[0m"
  echo -e "\033[0;37m   qi       — review inbox\033[0m"
}

# ── End of day ritual ────────────────────────────────────────────────────

eod() {
  local daily="${THOUGHTS_DIR}/daily.md"
  [[ -d "$THOUGHTS_DIR" ]] || mkdir -p "$THOUGHTS_DIR"

  echo -e "\033[1;36m━━━ End of Day ━━━\033[0m"
  echo ""

  echo "## EOD $(date '+%Y-%m-%d %H:%M')" >> "$daily"
  echo "Project: ${CURRENT_PROJECT:-?}" >> "$daily"

  read -p "Wat heb je gedaan? → " done_today
  read -p "Wat moet morgen eerst? → " tomorrow_first
  read -p "Waar loop je vast / wat blokkeert? → " blockers

  echo "- Gedaan: $done_today" >> "$daily"
  echo "- Morgen eerst: $tomorrow_first" >> "$daily"
  echo "- Blockers: $blockers" >> "$daily"
  echo "" >> "$daily"

  flowstop 2>/dev/null

  echo ""
  echo -e "\033[1;32m✅ Opgeslagen. Goed gedaan vandaag.\033[0m"
  echo -e "\033[0;37m   Laptop dicht. Ga iets leuks doen.\033[0m"
}

# ── "Wat moet ik nu doen" — for decision paralysis ──────────────────────

nu() {
  echo -e "\033[1;36m━━━ Wat nu? ━━━\033[0m"
  echo ""

  # Urgent inbox items
  if [[ -f "${THOUGHTS_DIR}/inbox.md" ]]; then
    local urgent=$(grep "🔴" "${THOUGHTS_DIR}/inbox.md" 2>/dev/null)
    if [[ -n "$urgent" ]]; then
      echo -e "\033[1;31m🔴 Urgent:\033[0m"
      echo "$urgent" | sed 's/^/  /'
      echo ""
    fi
  fi

  # TODOs in current project
  if [[ -n "$CURRENT_PROJECT" ]]; then
    local todos=$(grep -rn "TODO\|FIXME\|HACK\|XXX" . \
      --include='*.yaml' --include='*.yml' --include='*.sh' \
      --include='*.py' --include='*.go' --include='*.tf' \
      2>/dev/null | head -8)
    if [[ -n "$todos" ]]; then
      echo -e "\033[1;33m📋 TODOs in ${CURRENT_PROJECT}:\033[0m"
      echo "$todos" | sed 's/^/  /'
      echo ""
    fi
  fi

  # Recent worknotes
  if [[ -f ".worknotes" ]]; then
    echo -e "\033[1;33m📌 Laatste notities:\033[0m"
    tail -3 ".worknotes" | sed 's/^/  /'
    echo ""
  fi

  # Git status
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$dirty" -gt 0 ]]; then
      echo -e "\033[1;33m📝 ${dirty} uncommitted changes\033[0m"
    fi
  fi
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "flow" "flowstart" "Start 90 min deep work + break reminders"
_reg "flow" "flowstart <min>" "Start custom flow block (bijv: flowstart 45)"
_reg "flow" "flowstop" "Stop flow timer"
_reg "flow" "pomo <label>" "Pomodoro: 25 min focus"
_reg "ritual" "goedemorgen" "Ochtend-ritual: gisteren, inbox, agenda"
_reg "ritual" "eod" "Einde-dag ritual: samenvatten, morgen plannen"
_reg "ritual" "nu" "Wat moet ik nu doen? (voor decision paralysis)"
