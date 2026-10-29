#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=()

say() { printf '\n==> %s\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
    echo "run this as your normal user, not root" >&2
    exit 1
fi

command -v pacman >/dev/null || { echo "this is not an Arch system" >&2; exit 1; }

sudo -v

say "base tools"
sudo pacman -S --needed --noconfirm base-devel git rsync

say "AUR helper"
if ! command -v paru >/dev/null; then
    tmp="$(mktemp -d)"
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

say "packages"
mapfile -t WANTED < <(grep -v '^[[:space:]]*$' "$REPO/extras/packages-explicit.txt")
REPO_PKGS=()
AUR_PKGS=()
for p in "${WANTED[@]}"; do
    [ "$p" = paru ] && continue
    if pacman -Si "$p" >/dev/null 2>&1; then
        REPO_PKGS+=("$p")
    else
        AUR_PKGS+=("$p")
    fi
done
sudo pacman -S --needed --noconfirm "${REPO_PKGS[@]}"

for p in "${AUR_PKGS[@]}"; do
    paru -S --needed --noconfirm "$p" || FAILED+=("$p")
done

say "flatpak"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
while read -r app; do
    [ -z "$app" ] && continue
    sudo flatpak install -y --noninteractive flathub "$app" || FAILED+=("$app")
done < <(cut -f1 "$REPO/extras/flatpaks.txt")

say "configs"
rsync -a "$REPO/.config/" "$HOME/.config/"
rsync -a "$REPO/.local/" "$HOME/.local/"
if [ ! -f "$HOME/.config/dotfiles/config.json" ] && [ -f "$REPO/extras/dotfiles-config.json" ]; then
    mkdir -p "$HOME/.config/dotfiles"
    cp "$REPO/extras/dotfiles-config.json" "$HOME/.config/dotfiles/config.json"
fi
chmod +x "$HOME/.local/bin/"* "$HOME/.config/hypr/hyprland/scripts/"* 2>/dev/null || true

say "fonts and login theme"
mkdir -p "$HOME/.local/share/fonts"
cp -a "$REPO/extras/fonts/google-sans-flex" "$HOME/.local/share/fonts/"
"$REPO/extras/make-material-symbols-filled.py"
fc-cache -f >/dev/null
sudo cp -a "$REPO/extras/sddm/pixie" /usr/share/sddm/themes/
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=pixie\n' | sudo tee /etc/sddm.conf.d/20-pixie.conf >/dev/null

say "editor"
npm install -g monaco-editor || FAILED+=("monaco-editor")

say "shell and services"
sudo chsh -s /usr/bin/fish "$USER"
sudo systemctl enable sddm NetworkManager bluetooth fstrim.timer

say "colors"
if command -v matugen >/dev/null && command -v jq >/dev/null; then
    wallpaper="$(jq -r '.wallpaper.path // empty' "$HOME/.config/dotfiles/config.json" 2>/dev/null)"
    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        matugen image "$wallpaper" -m dark || true
    else
        echo "no wallpaper yet, colors stay as the committed seeds"
    fi
fi

say "done"
if [ ${#FAILED[@]} -gt 0 ]; then
    printf 'failed: %s\n' "${FAILED[*]}"
    exit 1
fi
echo "reboot to start the session"
