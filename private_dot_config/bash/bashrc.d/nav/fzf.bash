#!/usr/bin/env bash
# fzf.bash — Fuzzy file/directory navigation

# Edit any file in current project tree
fe() {
  local file
  file=$(find . -type f \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.terraform/*' \
    -not -path '*/vendor/*' \
    | fzf --prompt="edit: " --height=60% --reverse --preview 'head -50 {}')
  [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# cd into any directory with fzf
fd() {
  local dir
  dir=$(find . -type d \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.terraform/*' \
    | fzf --prompt="cd: " --height=40% --reverse)
  [[ -n "$dir" ]] && cd "$dir"
}

# Search file contents and jump to result
fgr() {
  local result
  result=$(grep -rn --color=never "${1:-.}" . \
    --include='*.yaml' --include='*.yml' --include='*.sh' \
    --include='*.py' --include='*.go' --include='*.tf' \
    --include='*.json' --include='*.toml' --include='*.md' \
    2>/dev/null \
    | fzf --ansi --prompt="grep: " --height=60% --reverse)
  if [[ -n "$result" ]]; then
    local file=$(echo "$result" | cut -d: -f1)
    local line=$(echo "$result" | cut -d: -f2)
    ${EDITOR:-vim} "+${line}" "$file"
  fi
}

# General navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Quick temp dir for throwaway experiments
tmp() {
  local d=$(mktemp -d /tmp/scratch-XXXX)
  cd "$d"
  echo "Scratch dir: $d (gone after reboot)"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "nav" "fe" "Edit file in project tree (fzf + preview)"
_reg "nav" "fd" "cd to directory (fzf)"
_reg "nav" "fgr <search>" "Grep in files, jump to result"
_reg "nav" "tmp" "Create throwaway scratch directory"
