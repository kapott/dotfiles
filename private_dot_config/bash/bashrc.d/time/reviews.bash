#!/usr/bin/env bash
# reviews.bash — Daily and weekly review rituals for task/time tracking

# Week start review
weekstart() {
    echo "=== OVERDUE ==="
    task overdue 2>/dev/null || echo "None"
    echo ""
    echo "=== DUE THIS WEEK ==="
    task due.before:sunday 2>/dev/null || echo "None"
    echo ""
    echo "=== BLOCKED ==="
    task blocked 2>/dev/null || echo "None"
    echo ""
    echo "=== TIME TRACKED THIS WEEK ==="
    timew summary :week 2>/dev/null || echo "Timewarrior not available"
}

# Daily review
dayreview() {
    echo "=== TODAY'S TASKS ==="
    task due:today 2>/dev/null || echo "None"
    echo ""
    echo "=== ACTIVE ==="
    task +ACTIVE 2>/dev/null || echo "None"
    echo ""
    echo "=== TIME TODAY ==="
    timew summary :day 2>/dev/null || echo "Timewarrior not available"
}

# End of day summary
dayend() {
    echo "=== COMPLETED TODAY ==="
    task end:today completed 2>/dev/null || echo "None"
    echo ""
    echo "=== TIME TRACKED TODAY ==="
    timew summary :day 2>/dev/null || echo "Timewarrior not available"
    echo ""
    echo "=== STILL ACTIVE ==="
    task +ACTIVE 2>/dev/null || echo "None"
}

# ── Registry ─────────────────────────────────────────────────────────────
_reg "review" "weekstart" "Week start review: overdue, due, blocked, time"
_reg "review" "dayreview" "Daily review: today's tasks, active, time"
_reg "review" "dayend" "End of day: completed, time tracked, still active"
