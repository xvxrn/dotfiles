#!/usr/bin/env bash
set -euo pipefail

COMMIT=5a224284872208b5324759d535d65061043725de
DEST="$HOME/.local/lib/hyprland"
TMP="$(mktemp -d)"

git clone --filter=blob:none https://github.com/VirtCode/hypr-dynamic-cursors "$TMP"
cd "$TMP"
git checkout -q "$COMMIT"

sed -i \
    -e 's/prop(NS("mode"), *"tilt"/prop(NS("mode"),                   "none"/' \
    -e 's/conf(NS("shake:ipc"), *false/conf(NS("shake:ipc"),              true/' \
    -e 's/conf(NS("shake:threshold"), *6\.0f/conf(NS("shake:threshold"),        3.0f/' \
    -e 's/conf(NS("shake:base"), *4\.0f/conf(NS("shake:base"),             2.2f/' \
    -e 's/conf(NS("shake:speed"), *4\.0f/conf(NS("shake:speed"),            1.5f/' \
    -e 's/conf(NS("shake:limit"), *0\.0f/conf(NS("shake:limit"),            3.0f/' \
    -e 's/conf(NS("shake:timeout"), *2000/conf(NS("shake:timeout"),          900/' \
    -e 's/conf(NS("hyprcursor:nearest"), *1/conf(NS("hyprcursor:nearest"),     0/' \
    src/config/ConfigManager.cpp

make all -j"$(nproc)" >/dev/null
strip --strip-debug out/dynamic-cursors.so

mkdir -p "$DEST"
install -m644 out/dynamic-cursors.so "$DEST/dynamic-cursors.so"
rm -rf "$TMP"

echo "installed $DEST/dynamic-cursors.so"
