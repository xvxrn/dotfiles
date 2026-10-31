#!/usr/bin/env bash
set -u

sound=0
[ "${1:-}" = "--sound" ] && sound=1

dir="$HOME/Videos"
mkdir -p "$dir" || exit 1

if pgrep -x wf-recorder > /dev/null; then
    pkill -x wf-recorder
    notify-send "Recording stopped" "$dir" -a Recorder
    exit 0
fi

out="$dir/recording_$(date '+%Y-%m-%d_%H.%M.%S').mp4"
args=(-x yuv420p -f "$out")

if [ "$sound" -eq 1 ]; then
    sink="$(pactl get-default-sink 2> /dev/null)"
    if [ -n "$sink" ]; then
        audio="${sink}.monitor"
    else
        audio="$(pactl list sources short | awk '/monitor/ {print $2; exit}')"
    fi
    [ -n "$audio" ] && args+=(--audio="$audio")
fi

notify-send "Recording started" "$out" -a Recorder
exec wf-recorder "${args[@]}"
