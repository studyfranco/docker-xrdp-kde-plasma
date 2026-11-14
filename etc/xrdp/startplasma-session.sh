#!/bin/sh
pulseaudio --start >/dev/null 2>&1 || true

xset s off && xset s noblank && xset -dpms
exec startplasma-x11
