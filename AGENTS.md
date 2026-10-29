# dotfiles

Personal XDG config for a Hyprland + Quickshell desktop on Arch. The shell is called `dotfiles`.
Plain files, no installer, no git repository yet. Derived from dots-hyprland; see `NOTICE.md`.

## Layout

- `.config/` — the XDG config tree, mirrors `~/.config`.
- `extras/` — configs that are not used. Copy back by hand if needed; see `extras/README.md`.
- `.config/hypr/hyprland/*.lua` — Hyprland config (Lua, not hyprlang).
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
  `.config/gtk-3.0/gtk.css`, `.config/gtk-4.0/gtk.css`.
- Terminal is kitty, file manager is Nautilus, editor is `~/.local/bin/monaco`. Launcher and
  power menu come from Quickshell.
- There is no zsh, foot, konsole, fuzzel, wlogout, mpv, dolphin, Kvantum or waffle panel
  family support. Do not reintroduce them as fallbacks.

## Verify

```sh
for f in .config/hypr/hyprland/*.lua .config/hypr/hyprland/services/*.lua .config/hypr/custom/*.lua; do luac -p "$f"; done
bash -n .config/quickshell/dotfiles/scripts/colors/switchwall.sh
python3 -c "import tomllib;tomllib.load(open('.config/matugen/config.toml','rb'))"
grep -rIn "illogical\|waffle\|quickshell/ii" .config
```
