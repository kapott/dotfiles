#!/usr/bin/env bash
# 40-loader.bash — Sources category subdirectories in order
#
# Loading order:
#   1. common/  - shared infrastructure (registry, notify)
#   2. flow/    - flow state, context, capture, guardrails
#   3. time/    - taskwarrior, timewarrior, reviews
#   4. nav/     - fzf, k8s, git, infra shortcuts

BASHRC_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc.d"

# Source all .bash files in a directory (sorted)
_source_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.bash; do
            [[ -f "$f" ]] && source "$f"
        done
    fi
}

# Load in dependency order
_source_dir "$BASHRC_DIR/common"   # registry must be first
_source_dir "$BASHRC_DIR/flow"
_source_dir "$BASHRC_DIR/time"
_source_dir "$BASHRC_DIR/nav"

unset -f _source_dir
