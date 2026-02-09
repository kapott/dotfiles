#!/usr/bin/env bash

# Recolor remaps
alias ls='ls --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias tmux='tmux -u'

# some more ls aliases
alias ll='ls -ahlF --group-directories-first'
alias la='ls -A'
alias l='ls -CF'

# One letter aliases
alias f='find'
alias g='git'
# t='task' is in time/tasks.bash
# c is managed by zoxide
# k is the kubectl wrapper in flow/guardrails.bash
alias l='ls'
alias m='mutt'
alias v='vim'
alias u='upg'
alias z='chezmoi'

# tmux quick-attach (tx since t=task)
alias tx='tmux new -AsBOFH'

# Two letter aliases
alias ff='find . -type f -name'
alias gh='history|grep'
alias sv='sudo vim'

# Three letter aliases
alias ffs='sudo !!'

# systemd shenanigans
alias s='systemctl'
alias scat='systemctl cat'
alias sstat='systemctl status'
alias srl='systemctl reload'
alias sstop='systemctl stop'
alias sstart='systemctl start'
alias stimers='systemctl list-timers --all'
alias aan='sstart'
alias uit='sstop'
alias log='journalctl -eu'
alias logf='journalctl -efu'

# certificate shenanigancs
alias crt_expiration='openssl x509 -enddate -noout -in'
alias crt_info='openssl x509 -noout -text -in'
alias crt_modulus='openssl x50 -noout -modulus -in'
alias key_modulus='openssl rsa -noout -modulus -in'
alias csr_modulus='openssl csr -noout -modulus -in'

