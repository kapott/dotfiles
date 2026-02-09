#!/usr/bin/env bash
# registry.sh — Command registry and fzf-powered discovery
# Source this FIRST — other files register into it.
#
# Design:
#   Each .sh file calls _reg to register its commands.
#   `h` opens fzf with preview showing what each command does.
#   `hh` prints a flat list (for piping, grepping).
#   Selected command from `h` gets inserted into your readline buffer.

declare -a _TOOLKIT_REGISTRY=()

# Register a command with category and description
# Usage: _reg "category" "command" "description"
_reg() {
  local cat="$1" cmd="$2" desc="$3"
  _TOOLKIT_REGISTRY+=("${cat}|${cmd}|${desc}")
}

# ── Interactive discovery with fzf ───────────────────────────────────────

h() {
  local filter="${1:-}"
  local selection

  selection=$(printf '%s\n' "${_TOOLKIT_REGISTRY[@]}" \
    | awk -F'|' '{printf "\033[1;33m%-12s\033[0m \033[1;36m%-16s\033[0m %s\n", $1, $2, $3}' \
    | { [[ -n "$filter" ]] && grep -i "$filter" || cat; } \
    | fzf --ansi \
          --prompt="command: " \
          --height=80% \
          --reverse \
          --header="↵ = copy to clipboard  |  ctrl-x = execute" \
          --preview='
            cmd=$(echo {} | awk "{print \$2}")
            echo "━━━ Details ━━━"
            echo ""
            # Try to show the function/alias definition
            type_out=$(type "$cmd" 2>/dev/null)
            if [ $? -eq 0 ]; then
              echo "$type_out"
            else
              echo "(no definition found — may need sourcing)"
            fi
          ' \
          --preview-window=right:50%:wrap \
          --bind="ctrl-x:become(echo EXEC:{2})" \
    )

  [[ -z "$selection" ]] && return 0

  # If ctrl-x was pressed, execute the command
  if [[ "$selection" == EXEC:* ]]; then
    local cmd="${selection#EXEC:}"
    echo -e "\033[0;37m→ ${cmd}\033[0m"
    eval "$cmd"
    return
  fi

  # Otherwise, extract command name and put it on the command line
  local cmd=$(echo "$selection" | awk '{print $2}')

  # Copy to clipboard if possible
  if command -v pbcopy &>/dev/null; then
    echo -n "$cmd" | pbcopy
    echo "📋 '${cmd}' gekopieerd"
  elif command -v xclip &>/dev/null; then
    echo -n "$cmd" | xclip -selection clipboard
    echo "📋 '${cmd}' gekopieerd"
  elif command -v wl-copy &>/dev/null; then
    echo -n "$cmd" | wl-copy
    echo "📋 '${cmd}' gekopieerd"
  else
    echo "→ ${cmd}"
  fi
}

# ── Flat list (greppable, scriptable) ────────────────────────────────────

hh() {
  local filter="${1:-}"
  printf '\n'
  printf '\033[1;37m%-12s %-16s %s\033[0m\n' "CATEGORY" "COMMAND" "DESCRIPTION"
  printf '%.0s─' {1..70}
  printf '\n'

  local last_cat=""
  printf '%s\n' "${_TOOLKIT_REGISTRY[@]}" \
    | sort -t'|' -k1,1 -k2,2 \
    | { [[ -n "$filter" ]] && grep -i "$filter" || cat; } \
    | while IFS='|' read -r cat cmd desc; do
        if [[ "$cat" != "$last_cat" ]]; then
          [[ -n "$last_cat" ]] && echo ""
          printf '\033[1;33m%-12s\033[0m \033[1;36m%-16s\033[0m %s\n' "$cat" "$cmd" "$desc"
        else
          printf '\033[1;33m%-12s\033[0m \033[1;36m%-16s\033[0m %s\n' "" "$cmd" "$desc"
        fi
        last_cat="$cat"
      done
  printf '\n'
}

# Register ourselves
_reg "help" "h" "Fuzzy-zoek door alle commands (fzf + preview)"
_reg "help" "h <filter>" "Zoek commands met filter (bijv: h kube)"
_reg "help" "hh" "Print alle commands als flat list"
_reg "help" "hh <filter>" "Print gefilterde command list"
