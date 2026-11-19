#!/usr/bin/env bash
# shellcheck disable=all
#
# Record system state while reproducing a desktop freeze
# (e.g. when starting Ardour in the music specialisation).
# Writes all logs to `./freeze-<timestamp>/` in the current directory.
#
# Usage: `sudo ./trace-freeze.sh [duration-seconds]` (default 120),
# then start `ardour9` as your user in another terminal.
# Stop early with Ctrl-C.

set -u

if [ "$(id -u)" != "0" ]; then
    echo "Must run as root (needs 'chrt -f 99' and the full journal)." >&2
    exit 1
fi

duration="${1:-120}"
out="$PWD/freeze-$(date +%F_%H%M%S)"
mkdir -p "$out" || exit 1

function cleanup() {
    trap - EXIT INT TERM
    kill $(jobs -p) 2>/dev/null
    wait 2>/dev/null

    summarize_gaps >"$out/heartbeat-gaps.txt"

    # Hand the logs back to the user who called sudo.
    if [ -n "${SUDO_USER:-}" ]; then
        chown -R "$SUDO_USER:" "$out"
    fi

    echo "Logs in '$out'."
    cat "$out/heartbeat-gaps.txt"
}

# Print every gap > 1 s between heartbeat ticks (tick interval is 0.2 s).
# A gap means normal (SCHED_OTHER) tasks did not get CPU time.
function summarize_gaps() {
    awk 'NR > 1 && $1 - prev > 1.0 {
            printf "heartbeat gap: %.2f s, from %s to %s\n",
                $1 - prev, strftime("%T", prev), strftime("%T", $1)
            n++
         }
         { prev = $1 }
         END { if (n == 0) print "heartbeat gap: none > 1 s" }' \
        "$out/heartbeat.log"
}

function snapshot_static() {
    echo "== date"
    date --iso-8601=seconds
    echo "== uname"
    uname -a
    echo "== cmdline"
    cat /proc/cmdline
    echo "== current-system"
    readlink /run/current-system
    echo "== sched_rt"
    grep . /proc/sys/kernel/sched_rt_runtime_us /proc/sys/kernel/sched_rt_period_us
    echo "== limits of user manager (${SUDO_USER:-?})"
    if [ -n "${SUDO_USER:-}" ]; then
        systemctl show "user@$(id -u "$SUDO_USER").service" -p LimitRTPRIO -p LimitMEMLOCK
        echo "== limits of sway"
        grep -E 'realtime priority|locked memory|open files' "/proc/$(pgrep -u "$SUDO_USER" -x sway | head -1)/limits" 2>/dev/null
    fi
    echo "== das_watchdog"
    systemctl status das_watchdog --no-pager 2>&1 | head -5
    echo "== memory"
    free -m
}

trap cleanup EXIT INT TERM

snapshot_static >"$out/static.txt" 2>&1

# Normal-priority heartbeat.
(while :; do
    date +%s.%N
    sleep 0.2
done) >"$out/heartbeat.log" &

# FIFO-99 samplers: they keep running even if RT threads take all CPU time.
# In `top`, a negative PR or `rt` marks a realtime thread.
chrt -f 99 top -b -H -d 1 -w 512 >"$out/top.log" 2>&1 &

chrt -f 99 bash -c 'while :; do
    echo "== $(date +%T.%N)"
    for f in cpu memory io; do echo "$f: $(tr "\n" " " </proc/pressure/$f)"; done
    sleep 1
done' >"$out/psi.log" 2>&1 &

# All realtime threads (class FF/RR), once per second.
# Shows when das_watchdog demotes them to TS.
chrt -f 99 bash -c 'while :; do
    echo "== $(date +%T.%N)"
    ps -eLo tid,pid,cls,rtprio,stat,comm | awk "NR == 1 || \$3 == \"FF\" || \$3 == \"RR\""
    sleep 1
done' >"$out/rt-threads.log" 2>&1 &

# Number of open file descriptors of sway and Xwayland, once per second.
chrt -f 99 bash -c 'while :; do
    line="$(date +%T.%N)"
    for p in sway Xwayland; do
        pid=$(pgrep -x "$p" | head -1)
        n=$( [ -n "$pid" ] && ls "/proc/$pid/fd" 2>/dev/null | wc -l)
        line+=" $p=${n:--}"
    done
    echo "$line"
    sleep 1
done' >"$out/fds.log" 2>&1 &

journalctl -f -o short-precise >"$out/journal.log" 2>&1 &
dmesg -wT >"$out/dmesg.log" 2>&1 &

echo "Logging to '$out' for $duration s. Start 'ardour9' now in another terminal."
sleep "$duration"
