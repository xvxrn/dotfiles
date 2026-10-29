# dotfiles

Personal XDG config for a Hyprland + Quickshell desktop on Arch. The shell is called `dotfiles`.
Plain files, no installer. Derived from dots-hyprland; see `NOTICE.md`.

## Restore on a fresh install

```sh
git clone <repo> ~/dotfiles
rsync -a ~/dotfiles/.config/ ~/.config/
```

Fonts are not in the repo. They come from packages and one manual install:

```sh
pacman -S ttf-jetbrains-mono-nerd ttf-material-symbols-variable
```

`Google Sans Flex` lives in `~/.local/share/fonts/illogical-impulse-google-sans-flex/` and must be
copied by hand before the first login; it is the `main`, `title` and `numbers` font.

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
python3 -c "import tomllib;tomllib.load(open('.config/matugen/config.toml','rb'))"
grep -rIn "illogical\|waffle\|quickshell/ii" .config
```
