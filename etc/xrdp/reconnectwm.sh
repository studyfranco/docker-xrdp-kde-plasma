#!/bin/sh
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
if [ -x /usr/libexec/pipewire-module-xrdp/load_pw_modules.sh ]; then
    /usr/libexec/pipewire-module-xrdp/load_pw_modules.sh >/dev/null 2>&1 || true
fi
