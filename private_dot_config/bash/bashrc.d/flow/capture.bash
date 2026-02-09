#!/usr/bin/env bash
# capture.sh — Frictionless thought capture
# Philosophy: capture now, organize later (or never — that's fine too)

THOUGHTS_DIR="${THOUGHTS_DIR:-$HOME/thoughts}"
INBOX_FILE="${THOUGHTS_DIR}/inbox.md"

# Ensure dir exists
[[ -d "$THOUGHTS_DIR" ]] || mkdir -p "$THOUGHTS_DIR"

# Quick capture — just dump it. Context is auto-added.
q() {
  if [[ -z "$*" ]]; then
    echo "Usage: q <gedachte, idee, todo, whatever>"
    return 1
  fi

  local ctx="${CURRENT_PROJECT:-general}"
  local ts=$(date '+%Y-%m-%d %H:%M')
  local kctx=$(kubectl config current-context 2>/dev/null || echo "none")

  echo "- [$ts] **[$ctx]** (k8s:$kctx) $*" >> "$INBOX_FILE"
  echo "💭 captured → inbox"
}

# Capture a TODO specifically (gets a checkbox)
qt() {
  local ctx="${CURRENT_PROJECT:-general}"
  local ts=$(date '+%Y-%m-%d %H:%M')
  echo "- [ ] [$ts] **[$ctx]** $*" >> "$INBOX_FILE"
  echo "☐ todo captured"
}

# Capture with priority flag
qq() {
  local ctx="${CURRENT_PROJECT:-general}"
  local ts=$(date '+%Y-%m-%d %H:%M')
  echo "- [$ts] 🔴 **[$ctx]** $*" >> "$INBOX_FILE"
  echo "🔴 urgent captured"
}

# Review inbox (fzf-powered)
qi() {
  if [[ ! -f "$INBOX_FILE" ]]; then
    echo "📭 Inbox is leeg"
    return 0
  fi

  echo -e "\033[1;36m━━━ Thought Inbox ($(wc -l < "$INBOX_FILE" | tr -d ' ') items) ━━━\033[0m"
  cat -n "$INBOX_FILE"
}

# Clear processed items from inbox
qi-clear() {
  if [[ -f "$INBOX_FILE" ]]; then
    local count=$(wc -l < "$INBOX_FILE" | tr -d ' ')
    local archive="${THOUGHTS_DIR}/archive-$(date '+%Y-%m-%d').md"
    cat "$INBOX_FILE" >> "$archive"
    > "$INBOX_FILE"
    echo "📦 ${count} items gearchiveerd → ${archive}"
  fi
}

# Daily scratch — for when you need a temporary thinking space
scratch() {
  local file="${THOUGHTS_DIR}/scratch-$(date '+%Y-%m-%d').md"
  if [[ ! -f "$file" ]]; then
    echo "# Scratch $(date '+%Y-%m-%d')" > "$file"
    echo "" >> "$file"
  fi
  ${EDITOR:-vim} "$file"
}

# Search through all captured thoughts
qg() {
  grep -rn --color=always "$*" "$THOUGHTS_DIR/" 2>/dev/null | fzf --ansi
}

# List open thoughts (unchecked TODOs)
ql() {
  if [[ ! -f "$INBOX_FILE" ]]; then
    echo "No thoughts yet. Use 'q' to capture one."
    return
  fi
  grep -n '^\- \[ \]' "$INBOX_FILE" | cat -n
}

# Mark done by number (from ql output)
qd() {
  [[ -z "$1" ]] && { echo "usage: qd <number>"; return 1; }
  local real_line
  real_line=$(grep -n '^\- \[ \]' "$INBOX_FILE" | sed -n "${1}p" | cut -d: -f1)
  [[ -z "$real_line" ]] && { echo "not found"; return 1; }
  sed -i'' "${real_line}s/- \[ \]/- [x]/" "$INBOX_FILE"
  echo "✓ done"
}

# Archive completed items to monthly file
qarchive() {
  local archive="${THOUGHTS_DIR}/archive-$(date +%Y-%m).md"
  grep '^\- \[x\]' "$INBOX_FILE" >> "$archive" 2>/dev/null
  local count
  count=$(grep -c '^\- \[x\]' "$INBOX_FILE" 2>/dev/null || echo 0)
  sed -i'' '/^\- \[x\]/d' "$INBOX_FILE"
  echo "✓ archived ${count} thoughts → ${archive}"
}

# Open inbox in editor for bulk review
qr() {
  ${EDITOR:-vim} "$INBOX_FILE"
}

# Stats: open/done counts and top tags
qs() {
  local open done
  open=$(grep -c '^\- \[ \]' "$INBOX_FILE" 2>/dev/null || echo 0)
  done=$(grep -c '^\- \[x\]' "$INBOX_FILE" 2>/dev/null || echo 0)
  echo "📬 open: ${open}  ✅ done: ${done}"
  local tags
  tags=$(grep -o '#[a-zA-Z0-9_]*' "$INBOX_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -5)
  [[ -n "$tags" ]] && echo "🏷  top tags:" && echo "$tags"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "capture" "q <tekst>" "Snelle thought capture (context-aware)"
_reg "capture" "qt <tekst>" "Capture als TODO met checkbox"
_reg "capture" "qq <tekst>" "Capture als URGENT 🔴"
_reg "capture" "qi" "Bekijk thought inbox"
_reg "capture" "qi-clear" "Archiveer inbox en maak leeg"
_reg "capture" "ql" "Lijst open TODOs (unchecked)"
_reg "capture" "qd <num>" "Markeer TODO als done (nummer uit ql)"
_reg "capture" "qarchive" "Archiveer voltooide items naar maandbestand"
_reg "capture" "qr" "Open inbox in editor"
_reg "capture" "qs" "Stats: open/done counts, top tags"
_reg "capture" "scratch" "Open dagelijks scratch-bestand in editor"
_reg "capture" "qg <zoek>" "Grep door alle thoughts (fzf)"
