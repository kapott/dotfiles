#!/usr/bin/env bash
# notify.sh — Cross-platform notifications
# Supports: macOS, i3/sway/hyprland (via notify-send), pure terminal fallback

_notify() {
  local title="${1:-Notification}"
  local body="${2:-}"
  local urgency="${3:-normal}" # low, normal, critical

  if [[ "$OSTYPE" == darwin* ]]; then
    osascript -e "display notification \"${body}\" with title \"${title}\"" 2>/dev/null
  elif command -v notify-send &>/dev/null; then
    # Works with dunst (i3), mako (sway), dunst/mako (hyprland)
    notify-send -u "$urgency" "$title" "$body" 2>/dev/null
  fi

  # Always also print to terminal — you might be staring at it
  local color="\033[1;33m"
  [[ "$urgency" == "critical" ]] && color="\033[1;31m"
  echo -e "${color}[${title}]\033[0m ${body}" >&2

  # Terminal bell as last resort
  printf '\a'
}

# Urgent variant for prod warnings etc
_notify_critical() {
  _notify "$1" "$2" "critical"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "internal" "_notify" "Stuur cross-platform notificatie (macOS/Linux)"
_reg "internal" "_notify_critical" "Urgente notificatie (blijft staan)"
