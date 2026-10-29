# TODO

Quickshell work (`~/.config/quickshell/dotfiles`, mirrored into this repo).

## Open

- Blur and `QT_QPA_PLATFORMTHEME` need a re-login check: Qt apps in the current session still run on the old environment.
- `opencode-symbolic.svg` in the bar reads as a white square at 20 px.
- The MangoWM port in `.config/mango/` has never been booted in a real session. `mango -p` passes, nothing more.
- Quickshell reads `hyprctl` in ten files, so the bar, workspaces, night light and theming do not work under MangoWM until it gets a backend.

## Done

- [x] AI panel on the left, opens with the same `slide left` animation as the quick settings panel
- [x] AI panel rewritten: title, harness/effort/model chips, message list, input
- [x] Bar buttons (AI, network, bluetooth) have no background in idle, hover or open state
- [x] Blur removed: `decoration.blur.enabled = false`, every `blur = true` layer rule dropped, dead `StyledBlurEffect.qml` deleted
- [x] Color picker works from the panel: the timer lived in a destroyed component, so it moved to a detached process; zoom restored, notification removed
- [x] Overview: action buttons to the right of app icons removed
- [x] Light theme for apps: `xdg-desktop-portal-gtk` crashed without `WAYLAND_DISPLAY` in the systemd environment, so the Settings portal never answered. Now `dbus-update-activation-environment --systemd --all` runs, the portal reports `prefer-dark`, and `QT_QPA_PLATFORMTHEME=kde` is set for Qt apps
- [x] Audit: dead code, duplicates, crashes
- [x] Material Symbols Filled as a static font instance
- [x] Harness icon blinking
- [x] Tooltips disabled globally
- [x] Moved from `illogical-impulse-quickshell-git` to quickshell from `extra`
- [x] Brightness and volume sliders in the panel
- [x] Media player only in the bar, middle click toggles play/pause
- [x] Clock: Todo and uptime removed

## Notes

- Light theme: `switchwall.sh` treats anything that is not `prefer-dark` as light, so a reset `gsettings` flips the desktop to light on the next wallpaper change.
