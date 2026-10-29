#!/usr/bin/env python3
"""Build the filled Material Symbols instance the shell uses for icons.

Qt ignores variable font axes in Quickshell, so FILL has to be baked into a static font.
Run this once per machine (needs python-fonttools), then restart the shell.

    ./extras/make-material-symbols-filled.py
"""
import os
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

SRC = "/usr/share/fonts/ttf-material-symbols-variable/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
DST = os.path.expanduser("~/.local/share/fonts/material-symbols-filled/MaterialSymbolsRoundedFilled.ttf")
FAMILY = "Material Symbols Rounded Filled"

font = instantiateVariableFont(TTFont(SRC), {"FILL": 1, "GRAD": 0, "wght": 600})
for record in font["name"].names:
    if record.nameID in (1, 16):
        record.string = FAMILY
    elif record.nameID == 4:
        record.string = FAMILY
    elif record.nameID == 6:
        record.string = "MaterialSymbolsRoundedFilled-Regular"
    elif record.nameID in (3, 17, 21, 22):
        record.string = "Regular"

os.makedirs(os.path.dirname(DST), exist_ok=True)
font.save(DST)
print(DST)
