#!/usr/bin/env bash
# git.bash — Git shortcuts

alias gs="git status -sb"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph -20"
alias gp="git push"
alias gpu="git pull"
alias gc="git commit"
alias gca="git commit --amend --no-edit"
alias gco="git checkout"
alias gb="git branch"

# lazygit if installed
command -v lazygit &>/dev/null && alias lg="lazygit"

# ── Registry ─────────────────────────────────────────────────────────────
_reg "git" "gs" "git status -sb"
_reg "git" "gd" "git diff"
_reg "git" "gds" "git diff --staged"
_reg "git" "gl" "git log --oneline --graph -20"
_reg "git" "gp" "git push"
_reg "git" "gpu" "git pull"
_reg "git" "gc" "git commit"
_reg "git" "gca" "git commit --amend --no-edit"
_reg "git" "gco" "git checkout"
_reg "git" "gb" "git branch"
_reg "git" "lg" "lazygit (if installed)"
