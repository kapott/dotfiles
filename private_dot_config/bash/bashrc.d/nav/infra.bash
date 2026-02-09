#!/usr/bin/env bash
# infra.bash — Helm, Terraform, Tmux shortcuts

# ── Tmux ────────────────────────────────────────────────────────────────
alias ta="tmux attach -t"
alias tls="tmux list-sessions"
alias tns="tmux new -s"
alias tks="tmux kill-session -t"

# Quick tmux session per project
twork() {
  local name="${1:-${CURRENT_PROJECT:-work}}"
  if tmux has-session -t "$name" 2>/dev/null; then
    tmux attach -t "$name"
  else
    tmux new-session -s "$name"
  fi
}

# ── Helm ────────────────────────────────────────────────────────────────
alias hl="helm list -A"
alias hstat="helm status"
alias hhist="helm history"

# ── Terraform ───────────────────────────────────────────────────────────
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfs="terraform state list"

# ── Registry ─────────────────────────────────────────────────────────────
_reg "tmux" "ta" "tmux attach -t"
_reg "tmux" "tls" "tmux list-sessions"
_reg "tmux" "tns" "tmux new -s"
_reg "tmux" "tks" "tmux kill-session -t"
_reg "tmux" "twork" "Open/attach tmux session for current project"
_reg "helm" "hl" "helm list -A"
_reg "helm" "hstat" "helm status"
_reg "helm" "hhist" "helm history"
_reg "terraform" "tf" "terraform"
_reg "terraform" "tfi" "terraform init"
_reg "terraform" "tfp" "terraform plan"
_reg "terraform" "tfa" "terraform apply"
_reg "terraform" "tfs" "terraform state list"
