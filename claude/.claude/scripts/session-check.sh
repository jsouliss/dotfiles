#!/usr/bin/env bash
# ~/.claude/scripts/session-check.sh
# Runs on SessionStart via hook — checks infrastructure health
# Writes results to /tmp/session-health.md

REPORT="/tmp/session-health.md"
PASS="✅"
FAIL="❌"
WARN="⚠️ "

echo "# Session Health Check — $(TZ='America/Los_Angeles' date '+%Y-%m-%d %H:%M %Z')" > "$REPORT"
echo "" >> "$REPORT"
echo "| Check | Status | Detail |" >> "$REPORT"
echo "|-------|--------|--------|" >> "$REPORT"

# 1. Discord .env accessibility
if [ -f ~/.claude/channels/discord/.env ]; then
    if [ -c ~/.claude/channels/discord/.env ]; then
        echo "| Discord .env | $WARN | Exists but shown as character device (sandbox-blocked) |" >> "$REPORT"
    else
        echo "| Discord .env | $PASS | Accessible |" >> "$REPORT"
    fi
else
    echo "| Discord .env | $FAIL | Not found |" >> "$REPORT"
fi

# 2. Discord MCP readiness (sandbox can't pgrep parent PID namespace — check file-based signals)
DISCORD_PLUGIN_DIR=~/.claude/plugins/cache/claude-plugins-official/discord
if [ -f ~/.claude/channels/discord/.env ] && [ -d "$DISCORD_PLUGIN_DIR" ]; then
    echo "| Discord MCP | $PASS | Plugin installed, .env present |" >> "$REPORT"
elif [ -d "$DISCORD_PLUGIN_DIR" ]; then
    echo "| Discord MCP | $WARN | Plugin installed but .env missing/blocked |" >> "$REPORT"
else
    echo "| Discord MCP | $FAIL | Plugin not installed |" >> "$REPORT"
fi

# 3. Hook script executable
if [ -x ~/.claude/scripts/session-check.sh ]; then
    echo "| Session hook | $PASS | Executable |" >> "$REPORT"
else
    echo "| Session hook | $WARN | Not executable |" >> "$REPORT"
fi

# 4. Claude sockets (stale detection)
SOCKET_COUNT=$(ls /tmp/claude-*.sock 2>/dev/null | wc -l)
SESSIONS=$((SOCKET_COUNT / 2))
if [ "$SESSIONS" -gt 2 ]; then
    echo "| Claude sockets | $WARN | $SESSIONS sessions — likely stale sockets |" >> "$REPORT"
else
    echo "| Claude sockets | $PASS | $SESSIONS session(s) |" >> "$REPORT"
fi

# 5. Systemd timers
TIMER_COUNT=$(systemctl --user list-timers --no-pager 2>/dev/null | grep -c "\.timer" || true)
if [ "$TIMER_COUNT" -gt 0 ]; then
    echo "| Systemd timers | $PASS | $TIMER_COUNT timer(s) active |" >> "$REPORT"
else
    echo "| Systemd timers | $WARN | No user timers found |" >> "$REPORT"
fi

# 6. Disk usage
DISK_PCT=$(df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %')
if [ "$DISK_PCT" -ge 85 ]; then
    echo "| Disk usage | $FAIL | ${DISK_PCT}% — critical |" >> "$REPORT"
elif [ "$DISK_PCT" -ge 70 ]; then
    echo "| Disk usage | $WARN | ${DISK_PCT}% — getting full |" >> "$REPORT"
else
    echo "| Disk usage | $PASS | ${DISK_PCT}% used |" >> "$REPORT"
fi

# 7. Memory & swap
MEM_AVAIL=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
SWAP_USED=$(awk '/SwapTotal/ {total=$2} /SwapFree/ {free=$2} END {print int((total-free)/1024)}' /proc/meminfo)
if [ "$MEM_AVAIL" -lt 256 ]; then
    echo "| Memory | $FAIL | ${MEM_AVAIL}MB available — low |" >> "$REPORT"
elif [ "$MEM_AVAIL" -lt 512 ]; then
    echo "| Memory | $WARN | ${MEM_AVAIL}MB available |" >> "$REPORT"
else
    echo "| Memory | $PASS | ${MEM_AVAIL}MB available |" >> "$REPORT"
fi
if [ "$SWAP_USED" -gt 1024 ]; then
    echo "| Swap | $WARN | ${SWAP_USED}MB used — heavy swapping |" >> "$REPORT"
else
    echo "| Swap | $PASS | ${SWAP_USED}MB used |" >> "$REPORT"
fi

# 8. Pending session-log action items
OPEN_ISSUES=$(grep -c "^\- \[ \]" ~/.claude/session-log.md 2>/dev/null || echo "0")
if [ "$OPEN_ISSUES" -gt 0 ]; then
    echo "| Open issues | $WARN | $OPEN_ISSUES item(s) in session-log.md |" >> "$REPORT"
else
    echo "| Open issues | $PASS | All clear |" >> "$REPORT"
fi

# 9. DR doc staleness check
DR_DOC="$HOME/Magi/docs/runbooks/nimbus-disaster-recovery.md"
if [ -f "$DR_DOC" ]; then
    LAST_COMMIT=$(git -C "$HOME/Magi" log -1 --format="%ct" -- docs/runbooks/nimbus-disaster-recovery.md 2>/dev/null)
    if [ -n "$LAST_COMMIT" ]; then
        NOW=$(date +%s)
        DAYS_OLD=$(( (NOW - LAST_COMMIT) / 86400 ))
        if [ "$DAYS_OLD" -gt 30 ]; then
            echo "| DR doc | $WARN | Last committed $DAYS_OLD days ago — consider updating |" >> "$REPORT"
        else
            echo "| DR doc | $PASS | Last committed $DAYS_OLD day(s) ago |" >> "$REPORT"
        fi
    else
        echo "| DR doc | $WARN | Not yet committed to git |" >> "$REPORT"
    fi
else
    echo "| DR doc | $FAIL | Not found at $DR_DOC |" >> "$REPORT"
fi

# 10. Failed user-manager units — gracefully skip if sandbox has no dbus access
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FAILED_USER_OUT=$(systemctl --user --failed --no-legend --no-pager 2>&1)
FAILED_USER_RC=$?
if [ "$FAILED_USER_RC" -ne 0 ]; then
    echo "| Failed user units | $WARN | Probe unavailable (dbus blocked in this context) |" >> "$REPORT"
elif [ -z "$FAILED_USER_OUT" ]; then
    echo "| Failed user units | $PASS | None |" >> "$REPORT"
else
    FIRST_FAILED=$(echo "$FAILED_USER_OUT" | head -1 | awk '{print $1}')
    COUNT=$(echo "$FAILED_USER_OUT" | wc -l)
    echo "| Failed user units | $FAIL | $COUNT failed (first: $FIRST_FAILED) |" >> "$REPORT"
fi

# 11. claude-mem MCP freshness — sandbox can't pgrep parent namespace, so check log mtime
CLAUDE_MEM_LOG_DIR=~/.claude-mem/logs
if [ -d "$CLAUDE_MEM_LOG_DIR" ]; then
    LATEST_LOG=$(ls -t "$CLAUDE_MEM_LOG_DIR"/claude-mem-*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        LOG_AGE_MIN=$(( ($(date +%s) - $(stat -c %Y "$LATEST_LOG")) / 60 ))
        if [ "$LOG_AGE_MIN" -lt 120 ]; then
            echo "| claude-mem MCP | $PASS | Log written ${LOG_AGE_MIN}min ago |" >> "$REPORT"
        else
            echo "| claude-mem MCP | $WARN | Latest log ${LOG_AGE_MIN}min old — may be idle or dead |" >> "$REPORT"
        fi
    else
        echo "| claude-mem MCP | $WARN | No logs found |" >> "$REPORT"
    fi
else
    echo "| claude-mem MCP | $FAIL | Log dir missing |" >> "$REPORT"
fi

# 12. Discord gateway rate-limit hint — scan webhook error logs ONLY (claude-mem.log would feedback-loop
# on logged Bash commands containing the pattern string; health-check.log contains ms timestamps ending .429).
# Pattern is HTTP-status scoped: "HTTP 429", "Retry-After:", and literal "rate limit exceeded".
TODAY=$(date +%Y-%m-%d)
GATEWAY_HITS=0
for f in ~/Magi/logs/webhook-errors.log ~/Magi/logs/discord-gateway-$TODAY.log; do
    [ -f "$f" ] || continue
    H=$(grep -cE "HTTP 429|Retry-After|rate limit exceeded" "$f" 2>/dev/null)
    GATEWAY_HITS=$(( GATEWAY_HITS + ${H:-0} ))
done
if [ "$GATEWAY_HITS" -gt 0 ]; then
    echo "| Discord gateway | $WARN | $GATEWAY_HITS rate-limit signal(s) in today's logs |" >> "$REPORT"
else
    echo "| Discord gateway | $PASS | No rate-limit signals today |" >> "$REPORT"
fi

# 13. Dump systemd timer/service state for in-session reading (D-Bus blocked inside sandbox)
systemctl --user list-timers --all > /tmp/systemd-timers.txt 2>&1
systemctl --user list-units --type=service --all > /tmp/systemd-services.txt 2>&1

echo "" >> "$REPORT"
echo "_Report: ${REPORT}_" >> "$REPORT"
