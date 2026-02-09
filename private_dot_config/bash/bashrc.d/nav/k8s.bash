#!/usr/bin/env bash
# k8s.bash — Kubectl shortcuts and fzf helpers

# ── kubectl aliases ─────────────────────────────────────────────────────
alias kgp="k get pods"
alias kgpa="k get pods -A"
alias kgn="k get nodes"
alias kgs="k get svc"
alias kgi="k get ingress"
alias kgd="k get deploy"
alias kgss="k get statefulset"
alias kge="k get events --sort-by=.lastTimestamp"
alias kga="k get all"
alias kdes="k describe"
alias kdel="k delete"
alias kaf="k apply -f"
alias kdf="k diff -f"
alias kex="k exec -it"
alias ktn="k top nodes"
alias ktp="k top pods"

# ── fzf-powered functions ───────────────────────────────────────────────

# Logs with fzf pod selection
klog() {
  local ns_flag=""
  [[ "$1" == "-A" ]] && ns_flag="--all-namespaces" && shift

  local selection
  selection=$(kubectl get pods $ns_flag --no-headers 2>/dev/null \
    | fzf --prompt="pod logs: " --height=40% --reverse)
  [[ -z "$selection" ]] && return 1

  if [[ -n "$ns_flag" ]]; then
    local ns=$(echo "$selection" | awk '{print $1}')
    local pod=$(echo "$selection" | awk '{print $2}')
    kubectl logs -f --tail=100 -n "$ns" "$pod" "$@"
  else
    local pod=$(echo "$selection" | awk '{print $1}')
    kubectl logs -f --tail=100 "$pod" "$@"
  fi
}

# Exec into a pod with fzf
ksh() {
  local pod
  pod=$(kubectl get pods --no-headers 2>/dev/null \
    | fzf --prompt="exec into: " --height=40% --reverse \
    | awk '{print $1}')
  [[ -z "$pod" ]] && return 1
  kubectl exec -it "$pod" -- "${1:-/bin/sh}"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "k8s" "kgp" "kubectl get pods"
_reg "k8s" "kgpa" "kubectl get pods -A"
_reg "k8s" "kgn" "kubectl get nodes"
_reg "k8s" "kgs" "kubectl get svc"
_reg "k8s" "kgi" "kubectl get ingress"
_reg "k8s" "kgd" "kubectl get deploy"
_reg "k8s" "kgss" "kubectl get statefulset"
_reg "k8s" "kge" "kubectl get events (sorted)"
_reg "k8s" "kga" "kubectl get all"
_reg "k8s" "kdes" "kubectl describe"
_reg "k8s" "kdel" "kubectl delete"
_reg "k8s" "kaf" "kubectl apply -f"
_reg "k8s" "kdf" "kubectl diff -f"
_reg "k8s" "kex" "kubectl exec -it"
_reg "k8s" "ktn" "kubectl top nodes"
_reg "k8s" "ktp" "kubectl top pods"
_reg "k8s" "klog" "Pod logs with fzf selection"
_reg "k8s" "ksh" "Exec shell in pod (fzf)"
