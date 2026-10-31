# mango

Port of the Hyprland config to MangoWM. Parked here, not installed.

Status: the config validates (`mango -p extras/mango/config.conf`) but the port was booted once and
did not work: `quickshell` came up broken, and the session had to be shut down from a TTY. Nothing
here has been debugged yet.

`.config/quickshell/dotfiles` reads `hyprctl` in about ten files, so the bar, workspaces, night light
and theming stay empty under MangoWM until the shell gets a MangoWM backend. That is the first thing
to fix before retrying.

To try it:

```sh
cp -a extras/mango ~/.config/mango
cp extras/mango/matugen-template/colors.conf ~/.config/matugen/templates/mango/colors.conf
# add the [templates.mango] block back to .config/matugen/config.toml
mango -p -c ~/.config/mango/config.conf
```

The matugen template was removed from `.config/matugen/config.toml` together with the config, so
that a fresh install never generates `~/.config/mango/colors.conf` for a session nobody starts.
