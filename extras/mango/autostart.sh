#!/usr/bin/env bash
set -u

"$HOME/.config/mango/scripts/start_geoclue_agent.sh"
qs -c dotfiles &
gnome-keyring-daemon --start --components=secrets
dbus-update-activation-environment --all
sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

if command -v easyeffects > /dev/null 2>&1; then
    easyeffects --hide-window --service-mode &
fi

wl-paste --type text --watch bash -c 'cliphist store && qs -c dotfiles ipc call cliphistService update' &
wl-paste --type image --watch bash -c 'cliphist store && qs -c dotfiles ipc call cliphistService update' &

if command -v hypridle > /dev/null 2>&1; then
    hypridle -c "$HOME/.config/mango/hypridle.conf" &
fi
