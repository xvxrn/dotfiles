#!/usr/bin/env bash
set -u

dir="${1:-$HOME/Pictures/Wallpapers}"
mapfile -d '' files < <(find "$dir" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \) -print0 2> /dev/null)

[ "${#files[@]}" -gt 0 ] || exit 1

qs -c dotfiles ipc call wallpapers apply "${files[RANDOM % ${#files[@]}]}"
