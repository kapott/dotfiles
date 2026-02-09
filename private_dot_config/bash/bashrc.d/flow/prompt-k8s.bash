#!/usr/bin/env bash
# prompt.sh — Context-aware prompt
# Solves: "which cluster am I on?" panic
# Choose ONE: the bash PS1 below, or the starship.toml config

# ── Option A: Pure bash PS1 (no dependencies) ───────────────────────────

_prompt_kube() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  [[ -z "$ctx" ]] && return
  local ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
  ns="${ns:-default}"

  if [[ "$ctx" =~ (prod|prd|live) ]]; then
    echo -e "\033[1;31m⎈ ${ctx}/${ns}\033[0m"
  else
    echo -e "\033[0;33m⎈ ${ctx}/${ns}\033[0m"
  fi
}

_prompt_project() {
  [[ -n "$CURRENT_PROJECT" ]] && echo -e "\033[1;36m[${CURRENT_PROJECT}]\033[0m "
}

_prompt_git() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return
  local dirty=""
  [[ -n $(git status --porcelain 2>/dev/null) ]] && dirty="*"
  echo -e "\033[0;35m ${branch}${dirty}\033[0m"
}

# Uncomment to use bash prompt (comment out if using starship)
# PS1='\n$(_prompt_kube) $(_prompt_project)\[\e[1;34m\]\w\[\e[0m\]$(_prompt_git)\n\$ '

# ── Option B: Starship config (recommended) ──────────────────────────────
# Save this as ~/.config/starship.toml

_generate_starship_config() {
  cat << 'STARSHIP_EOF'
# ~/.config/starship.toml — Flow-optimized prompt
# Clear context at a glance, dangerous environments scream at you

format = """
$kubernetes\
$custom\
$directory\
$git_branch\
$git_status\
$line_break\
$character"""

# Red background when on prod cluster
[kubernetes]
disabled = false
format = '[$symbol$context/$namespace]($style) '
style = 'bold yellow'
detect_files = []
detect_folders = []
detect_extensions = []

# This requires context-patterns in starship — alternatively use the
# [kubernetes.context_aliases] section
[[kubernetes.contexts]]
context_pattern = '.*(prod|prd|live).*'
style = 'bold red'
symbol = '⚠️ ⎈ '

[[kubernetes.contexts]]
context_pattern = '.*'
style = 'bold yellow'
symbol = '⎈ '

[directory]
truncation_length = 3
truncation_symbol = '…/'
style = 'bold blue'

[git_branch]
format = '[$symbol$branch]($style) '
style = 'purple'

[git_status]
format = '[$all_status$ahead_behind]($style) '
style = 'red'

[character]
success_symbol = '[❯](green)'
error_symbol = '[❯](red)'

# Show CURRENT_PROJECT env var
[env_var.CURRENT_PROJECT]
variable = 'CURRENT_PROJECT'
format = '[$symbol\[$env_value\]]($style) '
style = 'bold cyan'
symbol = ''

[cmd_duration]
min_time = 5_000
format = '[took $duration]($style) '
style = 'yellow'

# Hide stuff we don't need
[package]
disabled = true
[nodejs]
disabled = true
[python]
disabled = true
STARSHIP_EOF
}

# Generate starship config if requested
install-starship-config() {
  local target="${HOME}/.config/starship.toml"
  if [[ -f "$target" ]]; then
    read -p "Overschrijf bestaande starship.toml? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || return 1
  fi
  mkdir -p "$(dirname "$target")"
  _generate_starship_config > "$target"
  echo "✅ Starship config geschreven naar $target"
  echo "   Herstart je shell of run: eval \"\$(starship init bash)\""
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "setup" "install-starship-config" "Genereer starship.toml met k8s+project prompt"
