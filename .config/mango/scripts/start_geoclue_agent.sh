#!/usr/bin/env bash

if pgrep -f 'geoclue-2.0/demos/agent' > /dev/null; then
    exit 0
fi

AGENT_PATHS=(
    /usr/libexec/geoclue-2.0/demos/agent
    /usr/lib/geoclue-2.0/demos/agent
    "$HOME/.nix-profile/libexec/geoclue-2.0/demos/agent"
    "$HOME/.nix-profile/lib/geoclue-2.0/demos/agent"
    /run/current-system/sw/libexec/geoclue-2.0/demos/agent
)

for path in "${AGENT_PATHS[@]}"; do
    if [ -x "$path" ]; then
        "$path" &
        exit 0
    fi
done

exit 1
