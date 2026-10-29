# TODO

## Open

- The MangoWM port in `.config/mango/` has never been booted in a real session. `mango -p` passes, nothing more.
- Quickshell reads `hyprctl` in ten files, so the bar, workspaces, night light and theming do not work under MangoWM until it gets a backend.
- The OpenCode icon in the bar renders as a filled square instead of the logo.

## Notes

- Blur is off on purpose: `decoration.blur.enabled = false`, every window gets `no_blur`, and the old `StyledBlurEffect.qml` is gone.
- Light theme: `switchwall.sh` treats anything that is not `prefer-dark` as light, so a reset `gsettings` flips the desktop to light on the next wallpaper change.
