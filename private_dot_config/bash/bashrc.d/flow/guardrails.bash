#!/usr/bin/env bash
# guardrails.sh — Safety nets for working with ~30 clusters in sensitive sectors
# Solves: one wrong context = catastrophe in defense/energy infra

# ── Dangerous context detection ──────────────────────────────────────────

_is_dangerous_context() {
  local ctx="${1:-$(kubectl config current-context 2>/dev/null)}"
  # Customize these patterns for your naming convention
  [[ "$ctx" =~ (prod|prd|live|master|main|hub) ]] && return 0
  return 1
}

_show_context_warning() {
  local ctx=$(kubectl config current-context 2>/dev/null || echo "UNKNOWN")
  if _is_dangerous_context "$ctx"; then
    echo -e "\033[1;41;37m ⚠️  PRODUCTIE: ${ctx} \033[0m" >&2
  fi
}

# ── Safe kubectl wrapper ─────────────────────────────────────────────────

k() {
  local ctx=$(kubectl config current-context 2>/dev/null || echo "UNKNOWN")

  # Detect destructive operations
  local destructive=false
  case "$1" in
    delete|drain|cordon|taint|replace|patch|edit|scale)
      destructive=true
      ;;
    apply|create)
      # apply/create in prod also needs attention
      _is_dangerous_context "$ctx" && destructive=true
      ;;
  esac

  if $destructive && _is_dangerous_context "$ctx"; then
    echo -e "\033[1;41;37m ⚠️  DESTRUCTIEVE OPERATIE OP PRODUCTIE \033[0m" >&2
    echo -e "\033[1;31m Context: ${ctx}\033[0m" >&2
    echo -e "\033[1;31m Command: kubectl $*\033[0m" >&2
    echo "" >&2
    read -p "Type de context-naam om te bevestigen: " confirm
    if [[ "$confirm" != "$ctx" ]]; then
      echo "❌ Afgebroken."
      return 1
    fi
  elif _is_dangerous_context "$ctx"; then
    # Non-destructive but still in prod — just show a reminder
    echo -e "\033[1;33m[${ctx}]\033[0m" >&2
  fi

  kubectl "$@"
}

# ── Safe context switching ───────────────────────────────────────────────

# Switch context with fzf and clear visual feedback
kctx() {
  local new_ctx
  if [[ -n "$1" ]]; then
    new_ctx="$1"
  else
    new_ctx=$(kubectl config get-contexts -o name | fzf --prompt="k8s context: " --height=40% --reverse)
    [[ -z "$new_ctx" ]] && return 1
  fi

  kubectl config use-context "$new_ctx"

  # Loud visual feedback so you KNOW where you are
  if _is_dangerous_context "$new_ctx"; then
    echo -e "\033[1;41;37m"
    echo "  ██████╗ ██████╗  ██████╗ ██████╗  "
    echo "  ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗ "
    echo "  ██████╔╝██████╔╝██║   ██║██║  ██║ "
    echo "  ██╔═══╝ ██╔══██╗██║   ██║██║  ██║ "
    echo "  ██║     ██║  ██║╚██████╔╝██████╔╝ "
    echo "  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝  "
    echo "  Context: ${new_ctx}"
    echo -e "\033[0m"
  else
    echo -e "\033[1;32m✓ Context: ${new_ctx}\033[0m"
  fi
}

# Switch namespace with fzf
kns() {
  local ns
  if [[ -n "$1" ]]; then
    ns="$1"
  else
    ns=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | fzf --prompt="namespace: " --height=40% --reverse)
    [[ -z "$ns" ]] && return 1
  fi
  kubectl config set-context --current --namespace="$ns"
  echo -e "\033[1;32m✓ Namespace: ${ns}\033[0m"
}

# ── Quick cluster overview ───────────────────────────────────────────────

# "Where am I and is everything okay?"
kstatus() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  local ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
  ns="${ns:-default}"

  echo -e "\033[1;36m━━━ Cluster Status ━━━\033[0m"
  echo "Context:   $ctx"
  echo "Namespace: $ns"
  echo ""

  echo -e "\033[1;33mNodes:\033[0m"
  kubectl get nodes --no-headers 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "NotReady"; then
      echo -e "  \033[1;31m${line}\033[0m"
    else
      echo "  $line"
    fi
  done
  echo ""

  echo -e "\033[1;33mProbleem-pods:\033[0m"
  local problems=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null \
    | grep -v "Running\|Completed\|Succeeded")
  if [[ -n "$problems" ]]; then
    echo "$problems" | sed 's/^/  /'
  else
    echo -e "  \033[1;32m✓ Alles running\033[0m"
  fi
}

# ── ArgoCD helpers ───────────────────────────────────────────────────────

argo-unhealthy() {
  argocd app list -o wide 2>/dev/null | grep -v "Healthy.*Synced" | head -20
}

argo-sync() {
  local app="$1"
  if [[ -z "$app" ]]; then
    app=$(argocd app list -o name 2>/dev/null | fzf --prompt="Sync app: " --height=40% --reverse)
    [[ -z "$app" ]] && return 1
  fi
  echo "Syncing: $app"
  argocd app sync "$app"
}

# ── Vault helpers ────────────────────────────────────────────────────────

vault-status() {
  echo -e "\033[1;36m━━━ Vault Status ━━━\033[0m"
  vault status 2>/dev/null || echo "❌ Vault niet bereikbaar of niet ingelogd"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "k8s" "k" "Kubectl wrapper met prod-guardrails"
_reg "k8s" "kctx" "Switch k8s context (fzf) met visuele feedback"
_reg "k8s" "kctx <naam>" "Switch naar specifieke k8s context"
_reg "k8s" "kns" "Switch namespace (fzf)"
_reg "k8s" "kns <naam>" "Switch naar specifieke namespace"
_reg "k8s" "kstatus" "Cluster overview: nodes, probleem-pods"
_reg "argocd" "argo-unhealthy" "Toon niet-healthy ArgoCD apps"
_reg "argocd" "argo-sync" "Sync ArgoCD app (fzf)"
_reg "vault" "vault-status" "Check Vault status"
