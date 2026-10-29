# dotfiles

Personal XDG config for a Hyprland + Quickshell desktop on Arch. The shell is called `dotfiles`.
Plain files, no installer. Derived from dots-hyprland; see `NOTICE.md`.

## Restore on a fresh install

```sh
git clone <repo> ~/dotfiles && ~/dotfiles/extras/install.sh
```

The script installs packages (repo and AUR), flatpaks, configs, fonts, the SDDM theme and
`monaco-editor`, then enables `sddm`, `NetworkManager`, `bluetooth` and `fstrim.timer`.

Quickshell comes from `extra`, not from an `illogical-impulse` package: upstream 0.3.2 is the version
the shell runs on, and Arch rebuilds it whenever Qt changes, so no local rebuild is ever needed.

Not installable from a package, therefore vendored: `Google Sans Flex` in
`extras/fonts/google-sans-flex/` (the `main`, `title` and `numbers` font) and the SDDM theme
`pixie` in `extras/sddm/pixie/`.

Icons need one generated font too, because Qt ignores variable font axes in Quickshell and the
filled Material Symbols weight has to be baked in. Restart the shell after running it:

```sh
./extras/make-material-symbols-filled.py   # writes ~/.local/share/fonts/material-symbols-filled/
```

The editor is `monaco`: `.local/bin/monaco` plus `.local/share/monaco-editor/` are in this repo and
need `node` and the global npm package:

```sh
npm install -g monaco-editor
```
The launcher resolves the package with `npm root -g`, so node can come from pacman or `~/.local/node`.

First boot does not depend on matugen: `hyprland/colors.lua`, `mango/colors.conf`, `kitty/colors.conf`
and the GTK css are committed as seeds and are overwritten on the first wallpaper change.
`~/.config/dotfiles/config.json` is not committed; the shell writes defaults on first start.

## Layout

- `.config/` — the XDG config tree, mirrors `~/.config`.
- `extras/` — machine state that is not part of the config. Nothing there is required.
- `.config/hypr/hyprland/*.lua` — Hyprland config (Lua, not hyprlang).
- `.config/mango/` — MangoWM port of the Hyprland config. Untested; Hyprland stays the default session.
- `.config/hypr/custom/*.lua` — upstream override hooks. Keep these header-only: personal
  tweaks go straight into `hyprland/*.lua` so there is one source of truth.
- `.config/quickshell/dotfiles/` — the shell. Upstream code; changes stay small and hand-merged.
- `.config/matugen/` — wallpaper color pipeline. Its outputs are not authored by hand.

## Names

The shell name `dotfiles` appears in several places and they must stay in sync:

- directory `.config/quickshell/dotfiles/`
- shell config directory `~/.config/dotfiles/` (`Directories.qml`, `switchwall.sh`, `applycolor.sh`)
- `hl.env("qsConfig", "dotfiles")` in `hyprland/variables.lua`, used as `qs -c $qsConfig`
- `QUICKSHELL_CONFIG_NAME` in the color scripts
- the fish alias `q 'qs -c dotfiles'`

## Conventions

- Everything in the repo is written in English.
- Do not stage or copy secrets or machine state: dotfile sources are the config that was written
  by hand, not browser profiles, credentials, `fish_variables`, thumbnails, or app caches.
- Generated, do not hand-edit: `.config/hypr/hyprland/colors.lua`,
  `.config/hypr/hyprlock/colors.conf`, `.config/kitty/colors.conf`,
  `.config/gtk-3.0/gtk.css`, `.config/gtk-4.0/gtk.css`, `.config/mango/colors.conf`.
  They are committed only as first-boot seeds; matugen overwrites them.
- Terminal is kitty, file manager is Nautilus, editor is `~/.local/bin/monaco`. Launcher and
  power menu come from Quickshell.
- There is no zsh, foot, konsole, fuzzel, wlogout, mpv, dolphin, Kvantum or waffle panel
  family support. Do not reintroduce them as fallbacks.

## Verify

```sh
for f in .config/hypr/hyprland/*.lua .config/hypr/hyprland/services/*.lua .config/hypr/custom/*.lua; do luac -p "$f"; done
bash -n .config/quickshell/dotfiles/scripts/colors/switchwall.sh
bash -n .config/mango/autostart.sh
mango -p -c .config/mango/config.conf
bash -n extras/install.sh
python3 -m py_compile extras/make-material-symbols-filled.py
python3 -c "import tomllib;tomllib.load(open('.config/matugen/config.toml','rb'))"
grep -rIn "illogical\|waffle\|quickshell/ii" .config
```
