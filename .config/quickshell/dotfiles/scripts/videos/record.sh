#!/usr/bin/env bash
# Screen recording. Running it again stops the active recording.
# Usage: record.sh [--region "x,y WxH"] [--fullscreen] [--sound]

CONFIG_FILE="$HOME/.config/dotfiles/config.json"
RECORDING_DIR="$(jq -r '.screenRecord.savePath' "$CONFIG_FILE" 2>/dev/null)"
[[ -z "$RECORDING_DIR" || "$RECORDING_DIR" == "null" ]] && RECORDING_DIR="$HOME/Videos"

getdate() { date '+%Y-%m-%d_%H.%M.%S'; }
getaudiooutput() {
    local sink
    sink="$(pactl get-default-sink 2>/dev/null)"
    if [[ -n "$sink" ]]; then
        echo "${sink}.monitor"
        return
    fi
    pactl list sources short | awk '/monitor/ {print $2; exit}'
}
getactivemonitor() { hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'; }

if pgrep -x wf-recorder > /dev/null; then
    pkill -x wf-recorder
    notify-send "Recording stopped" "$RECORDING_DIR" -a Recorder
    exit 0
fi

REGION=""
SOUND=0
FULLSCREEN=0
while (( $# > 0 )); do
    case "$1" in
        --region)   REGION="${2:-}"; shift 2 ;;
        --sound)    SOUND=1; shift ;;
        --fullscreen) FULLSCREEN=1; shift ;;
        *)          shift ;;
    esac
done

if [[ $FULLSCREEN -eq 0 && -z "$REGION" ]]; then
    if ! REGION="$(slurp)"; then
        notify-send "Recording cancelled" "Selection was cancelled" -a Recorder
        exit 1
    fi
fi

mkdir -p "$RECORDING_DIR" || exit 1
cd "$RECORDING_DIR" || exit 1
OUTFILE="recording_$(getdate).mp4"

ARGS=(-x yuv420p -f "$OUTFILE")
[[ $FULLSCREEN -eq 1 ]] && ARGS+=(-o "$(getactivemonitor)")
[[ -n "$REGION" ]] && ARGS+=(--geometry "$REGION")
[[ $SOUND -eq 1 ]] && ARGS+=(--audio="$(getaudiooutput)")

notify-send "Recording started" "$OUTFILE" -a Recorder
exec wf-recorder "${ARGS[@]}"
