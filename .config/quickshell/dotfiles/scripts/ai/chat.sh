#!/usr/bin/env bash
# One chat turn for the shell's AI panel.
# usage: chat.sh <codex|claude|opencode> <model> <effort> <session-id> [cwd] [prompt]
# prompt falls back to stdin when omitted
# Emits one JSON object per line: {type:"session"|"text"|"tool"|"error"|"done", ...}
set -o pipefail

HARNESS="${1:-codex}"
MODEL="${2:-}"
EFFORT="${3:-medium}"
SESSION="${4:-}"
CWD="${5:-$HOME}"
PROMPT="${6:-}"
[[ -z "$PROMPT" ]] && PROMPT="$(cat)"
[[ -z "$PROMPT" ]] && { echo '{"type":"error","text":"empty prompt"}'; exit 1; }

normalize_codex() {
    jq -c '
        if .type == "thread.started" then {type: "session", id: .thread_id}
        elif .type == "item.completed" and .item.type == "agent_message" then {type: "text", text: .item.text}
        elif .type == "item.completed" and .item.type == "command_execution" then {type: "tool", text: .item.command}
        elif .type == "item.started" and .item.type == "command_execution" then {type: "tool_start", text: .item.command}
        elif .type == "turn.failed" then {type: "error", text: (.error.message // "turn failed")}
        elif .type == "error" then {type: "error", text: (.message // "error")}
        else empty end'
}

case "$HARNESS" in
codex)
    common=(--json --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox
            -c "model_reasoning_effort=\"$EFFORT\"")
    [[ -n "$MODEL" ]] && common+=(-m "$MODEL")
    if [[ -n "$SESSION" ]]; then
        printf '%s' "$PROMPT" | codex exec resume "${common[@]}" "$SESSION" - 2>&1 | normalize_codex
    else
        printf '%s' "$PROMPT" | codex exec "${common[@]}" -C "$CWD" - 2>&1 | normalize_codex
    fi
    ;;
claude)
    args=(-p --output-format stream-json --verbose
          --dangerously-skip-permissions --effort "$EFFORT")
    [[ -n "$MODEL" ]] && args+=(--model "$MODEL")
    [[ "${SESSION}" == *-* ]] && args+=(--resume "$SESSION")
    cd "$CWD" 2>/dev/null || true
    printf '%s' "$PROMPT" | claude "${args[@]}" 2>&1 | jq -c '. as $e |
        if $e.type == "system" and $e.subtype == "init" then {type: "session", id: $e.session_id}
        elif $e.type == "assistant" then
            $e.message.content[] |
                if .type == "text" then {type: "text", text: .text}
                elif .type == "tool_use" then {type: "tool", text: .name}
                else empty end
        elif $e.type == "result" and ($e.is_error // false) then {type: "error", text: ($e.result // "error")}
        else empty end'
    ;;
opencode)
    # shortcut: opencode is started fresh per turn with --session, which creates the
    # session on first use and continues it afterwards; no thread id is emitted back
    args=(run --format json --auto)
    [[ "${SESSION}" == ses_* ]] && args+=(--session "$SESSION")
    [[ -n "$MODEL" ]] && args+=(-m "$MODEL")
    cd "$CWD" 2>/dev/null || true
    opencode "${args[@]}" -- "$PROMPT" 2>&1 | jq -c '
        if .type == "step_start" then {type: "session", id: (.sessionID // "")}
        elif .type == "text" then {type: "text", text: (.part.text // ""), id: (.sessionID // "")}
        elif .type == "tool" then {type: "tool", text: (.part.tool // "")}
        elif .type == "error" then {type: "error", text: (.error.data.message // .error.name // "error")}
        else empty end'
    ;;
*)
    echo '{"type":"error","text":"unknown harness"}'
    exit 1
    ;;
esac

echo '{"type":"done"}'
