#!/bin/sh
if ! pgrep -u "$(id -u)" -x pipewire >/dev/null 2>&1; then
    rm -f "$XDG_RUNTIME_DIR"/pipewire-* "$XDG_RUNTIME_DIR"/pulse/native "$XDG_RUNTIME_DIR"/pulse/pid
    pipewire >/dev/null 2>&1 &
    i=0
    while [ "$i" -lt 30 ] && [ ! -S "$XDG_RUNTIME_DIR/pipewire-0" ]; do
        sleep 0.1
        i=$((i + 1))
    done
fi

if ! pgrep -u "$(id -u)" -x wireplumber >/dev/null 2>&1; then
    wireplumber >/dev/null 2>&1 &
fi

if ! pgrep -u "$(id -u)" -x pipewire-pulse >/dev/null 2>&1; then
    pipewire-pulse >/dev/null 2>&1 &
    i=0
    while [ "$i" -lt 30 ] && [ ! -S "$XDG_RUNTIME_DIR/pulse/native" ]; do
        sleep 0.1
        i=$((i + 1))
    done
fi

xset s off && xset s noblank && xset -dpms
exec startplasma-x11
