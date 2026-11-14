#!/bin/sh
if [ -r /etc/profile ]; then
    . /etc/profile
fi
if [ -r "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
if [ -r /etc/default/locale ]; then
    set -a
    . /etc/default/locale
    set +a
fi

export XDG_RUNTIME_DIR="/run/user/$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

exec /etc/X11/Xsession /etc/xrdp/startplasma-session.sh
