#!/usr/bin/env bash
# Active agent harness sessions: name<TAB>elapsed_seconds<TAB>cwd
# shortcut: matches command lines, so a harness started through a wrapper may be missed; extend PATTERN when adding one
PATTERN=' (opencode|codex|claude|gemini|aider|crush)( |$)'

while read -r pid etimes args; do
    [[ "$args" == *harness-sessions.sh* ]] && continue
    name=${args%% *}
    name=${name##*/}
    cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null) || continue
    printf '%s\t%s\t%s\n' "$name" "$etimes" "$cwd"
done < <(ps -eo pid=,etimes=,args= | grep -E "$PATTERN" | grep -v ' grep ')
