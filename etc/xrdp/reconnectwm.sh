#!/bin/sh
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
if [ -x /usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh ]; then
    /usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh >/dev/null 2>&1 || true
fi
