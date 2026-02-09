# Bash Configuration

Modular shell configuration for infrastructure engineers. Integrates project management, task tracking, time tracking, and kubernetes workflows.

## A Typical Day

```bash
# Morning: start the day
goedemorgen                    # Shows yesterday's EOD notes, inbox items, calendar
workon                         # Pick a project with fzf → see worknotes, git, tasks

# Working: stay in flow
tstart                         # Start a task (fzf picker) → begins time tracking
wn "debugging auth issue"      # Leave breadcrumb for future you
q "idea: refactor login flow"  # Capture thought without losing focus
flowstart 90                   # Start 90-min focus block with break reminders

# Quick task management
tadd "fix nginx config"        # Add task to current project
tl                             # List tasks
tdone                          # Complete a task (fzf)

# Kubernetes work
kctx                           # Switch k8s context (fzf) with visual prod warning
kgp                            # Get pods
klog                           # Tail logs (fzf pod picker)
k apply -f deploy.yaml         # Apply with prod guardrails

# End of day
tstop                          # Stop time tracking
eod                            # End-of-day ritual: what did you do, what's next
dayend                         # Review: completed tasks, time tracked
```

## Command Reference

Use `h` to fuzzy-search all commands, or `hh` for a flat list.

### Capture

| Command | Description |
|---------|-------------|
| `q <text>` | Quick thought capture (with project/k8s context) |
| `qarchive` | Archive completed items to monthly file |
| `qd <num>` | Mark TODO done (number from `ql`) |
| `qg <search>` | Grep through all thoughts (fzf) |
| `qi` | View thought inbox |
| `qi-clear` | Archive inbox and clear |
| `ql` | List open TODOs |
| `qq <text>` | Capture as urgent |
| `qr` | Open inbox in editor |
| `qs` | Stats: open/done counts, top tags |
| `qt <text>` | Capture as TODO with checkbox |
| `scratch` | Open daily scratch file in editor |

### Flow

| Command | Description |
|---------|-------------|
| `eod` | End-of-day ritual: summarize, plan tomorrow |
| `flowstart [min]` | Start focus block (default 90 min) with break reminders |
| `flowstop` | Stop flow timer |
| `goedemorgen` | Morning ritual: yesterday's notes, inbox, calendar |
| `nu` | "What now?" - shows urgent items, TODOs, blockers |
| `pomo <label>` | Pomodoro: 25 min focus timer |

### Git

| Command | Description |
|---------|-------------|
| `gb` | `git branch` |
| `gc` | `git commit` |
| `gca` | `git commit --amend --no-edit` |
| `gco` | `git checkout` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gl` | `git log --oneline --graph -20` |
| `gp` | `git push` |
| `gpu` | `git pull` |
| `gs` | `git status -sb` |
| `lg` | `lazygit` (if installed) |

### Helm

| Command | Description |
|---------|-------------|
| `hhist` | `helm history` |
| `hl` | `helm list -A` |
| `hstat` | `helm status` |

### Help

| Command | Description |
|---------|-------------|
| `h [filter]` | Fuzzy-search commands (fzf + preview) |
| `hh [filter]` | Print all commands as flat list |

### Kubernetes

| Command | Description |
|---------|-------------|
| `k` | kubectl wrapper with prod guardrails |
| `kaf` | `kubectl apply -f` |
| `kctx [name]` | Switch k8s context (fzf) with visual feedback |
| `kdes` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kdf` | `kubectl diff -f` |
| `kex` | `kubectl exec -it` |
| `kga` | `kubectl get all` |
| `kgd` | `kubectl get deploy` |
| `kge` | `kubectl get events` (sorted) |
| `kgi` | `kubectl get ingress` |
| `kgn` | `kubectl get nodes` |
| `kgp` | `kubectl get pods` |
| `kgpa` | `kubectl get pods -A` |
| `kgs` | `kubectl get svc` |
| `kgss` | `kubectl get statefulset` |
| `klog [-A]` | Pod logs with fzf selection |
| `kns [name]` | Switch namespace (fzf) |
| `ksh [shell]` | Exec shell in pod (fzf) |
| `kstatus` | Cluster overview: nodes, problem pods |
| `ktn` | `kubectl top nodes` |
| `ktp` | `kubectl top pods` |

### Navigation

| Command | Description |
|---------|-------------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `fd` | cd to directory (fzf) |
| `fe` | Edit file in project tree (fzf + preview) |
| `fgr <search>` | Grep in files, jump to result (fzf) |
| `tmp` | Create throwaway scratch directory |

### Project

| Command | Description |
|---------|-------------|
| `p` | Alias for `workon` |
| `poff` | Clear project context |
| `pp` | Peek - cd to project without context |
| `wn <text>` | Leave note for future you |
| `wn-all [days]` | Show notes from all projects |
| `workon [name]` | Switch project: worknotes + git + tasks + context |
| `worksave` | Save current tmux layout for project |

### Review

| Command | Description |
|---------|-------------|
| `dayend` | End of day: completed, time tracked, still active |
| `dayreview` | Daily review: today's tasks, active, time |
| `weekstart` | Week start: overdue, due, blocked, time |

### Task (Taskwarrior)

| Command | Description |
|---------|-------------|
| `t` | `task` |
| `ta` | `task add` |
| `tadd <desc>` | Add task to current project |
| `taddp <desc>` | Add task with project picker (fzf) |
| `tall` | `task all` |
| `tbackup` | Backup tasks to JSON |
| `tblock` | `task blocked` |
| `tcomp` | `task completed` |
| `tctx` | `task context` |
| `tctxn` | Clear task context |
| `tctxs` | `task context show` |
| `tdel` | `task delete` |
| `tdelf` | Delete task (fzf) |
| `tdone [id]` | Complete task (fzf if no id) |
| `te` | `task edit` |
| `ti` | `task info` |
| `tinbox` | `task +inbox` |
| `tl` | `task list` |
| `tmod` | `task modify` |
| `tmodf` | Modify task (fzf) |
| `tn` | `task next` |
| `tnxt` | `task +next` |
| `tover` | `task overdue` |
| `tpl` | List tasks for current project |
| `tproj` | `task projects` |
| `tready` | `task ready` |
| `tstart [id]` | Start task + time tracking (fzf if no id) |
| `tstop` | Stop current task + time tracking |
| `tsync` | `task sync` |
| `ttoday` | `task due:today` |
| `tunblock` | `task unblocked` |
| `tundo` | `task undo` |
| `turgent` | `task +urgent` |
| `twait` | `task waiting` |
| `tweek` | `task due.before:sunday` |
| `vt` | `vit` (taskwarrior TUI) |

### Terraform

| Command | Description |
|---------|-------------|
| `tf` | `terraform` |
| `tfa` | `terraform apply` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfs` | `terraform state list` |

### Timewarrior

| Command | Description |
|---------|-------------|
| `tw` | `timew` |
| `twback [min]` | Adjust start time by -N minutes |
| `twcurrent` | Show current tracking + active task |
| `twday` | `timew summary :day` |
| `twids` | `timew summary :ids` |
| `twlog <dur> <tags>` | Log past work (e.g., `twlog 2h coding`) |
| `twmonth` | `timew summary :month` |
| `twproj [proj]` | Start tracking project (fzf if no arg) |
| `tws` | `timew summary` |
| `twsp` | `timew stop` |
| `twst` | `timew start` |
| `twsumproj [proj]` | Time summary for project |
| `twtags` | `timew tags` |
| `twweek` | `timew summary :week` |

### Tmux

| Command | Description |
|---------|-------------|
| `ta` | `tmux attach -t` |
| `tks` | `tmux kill-session -t` |
| `tls` | `tmux list-sessions` |
| `tns` | `tmux new -s` |
| `twork [name]` | Open/attach tmux session for project |
| `tx` | Quick tmux attach (`tmux new -AsBOFH`) |

### Other

| Command | Description |
|---------|-------------|
| `argo-sync` | Sync ArgoCD app (fzf) |
| `argo-unhealthy` | Show unhealthy ArgoCD apps |
| `install-starship-config` | Generate starship.toml with k8s+project prompt |
| `upg` / `u` | Cross-distro system upgrade |
| `vault-status` | Check Vault status |

## Dependencies

**Required:** `fzf`, `jq`

**Time tracking:** `taskwarrior`, `timewarrior`

**Kubernetes:** `kubectl`, optionally `argocd`, `vault`

**Optional:** `starship`, `lazygit`, `zoxide`, `vit`, `direnv`

## Installation

Files are sourced from `~/.bashrc`:

```bash
for f in ~/.config/bash/bashrc.d/*.bash; do
  source "$f"
done
```

The numbered files load first, then `40-loader.bash` sources the category subdirectories (`common/`, `flow/`, `time/`, `nav/`).

## Taskwarrior Hook

For automatic time tracking when starting/stopping tasks:

```bash
cp ~/.config/bash/bashrc.d/time/on-modify.timewarrior ~/.task/hooks/
chmod +x ~/.task/hooks/on-modify.timewarrior
```
