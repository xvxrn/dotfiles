#!/usr/bin/env bash
set -u

if mmsg get keymode 2> /dev/null | grep -q 'virtual-machine'; then
    mmsg dispatch setkeymode,default
    notify-send "Exited Virtual Machine keymode" "Keybinds re-enabled" -a Mango
else
    mmsg dispatch setkeymode,virtual-machine
    notify-send "Entered Virtual Machine keymode" "Keybinds disabled. Hit SUPER+ALT+F1 to escape" -a Mango
fi
