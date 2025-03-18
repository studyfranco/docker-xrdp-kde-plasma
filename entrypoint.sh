#!/bin/bash

start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid 2> /dev/null
    rm -rf /var/run/xrdp.pid 2> /dev/null
    rm -rf /var/run/xrdp/xrdp-sesman.pid 2> /dev/null
    rm -rf /var/run/xrdp/xrdp.pid 2> /dev/null

    # Use exec ... to forward SIGNAL to child processes
    /usr/sbin/sssd -d 0x0100 --logger=files -D &
    /usr/bin/pulseaudio --system -D
    xrdp-sesman &
    exec xrdp --nodaemon
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}


echo Entryponit script is Running...

echo -e "starting xrdp services...\n"

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services