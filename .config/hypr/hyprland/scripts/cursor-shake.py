#!/usr/bin/env python3
import os
import select
import struct
import subprocess
import time

THEME = "Bibata-Modern-Classic"
BASE = 24
BIG = 72
SLIDE = 12
FLIPS = 4
SPAN = 0.5
HOLD = 0.7

EVENT = struct.Struct("llHHi")
REL = 2
REL_X = 0


def open_mice():
    fds = []
    for name in sorted(os.listdir("/dev/input")):
        if not name.startswith("event"):
            continue
        try:
            fds.append(os.open("/dev/input/" + name, os.O_RDONLY))
        except OSError:
            continue
    return fds


def main():
    fds = open_mice()
    if not fds:
        return

    size = BASE
    last_sign = 0
    flips = 0
    first = 0.0
    revert_at = None

    def setsize(new):
        nonlocal size
        if new != size:
            size = new
            subprocess.Popen(
                ["hyprctl", "setcursor", THEME, str(new)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    while True:
        if revert_at is None:
            timeout = None
        else:
            timeout = max(0.0, revert_at - time.monotonic())

        ready, _, _ = select.select(fds, [], [], timeout)
        now = time.monotonic()

        for fd in ready:
            data = os.read(fd, EVENT.size * 64)
            offset = 0
            while offset + EVENT.size <= len(data):
                _, _, etype, code, value = EVENT.unpack_from(data, offset)
                offset += EVENT.size
                if etype != REL or code != REL_X or revert_at is not None:
                    continue
                if value == 0 or abs(value) < SLIDE:
                    continue

                sign = 1 if value > 0 else -1
                if sign == last_sign:
                    continue
                last_sign = sign

                if flips == 0 or now - first > SPAN:
                    first = now
                    flips = 1
                    continue

                flips += 1
                if flips >= FLIPS:
                    flips = 0
                    setsize(BIG)
                    revert_at = now + HOLD

        if revert_at is not None and time.monotonic() >= revert_at:
            setsize(BASE)
            revert_at = None
            last_sign = 0
            flips = 0


main()
