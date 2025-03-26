#!/bin/bash

start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid 2> /dev/null
    rm -rf /var/run/xrdp.pid 2> /dev/null
    rm -rf /var/run/xrdp/xrdp-sesman.pid 2> /dev/null
    rm -rf /var/run/xrdp/xrdp.pid 2> /dev/null

    # Use exec ... to forward SIGNAL to child processes
    mkdir -p /var/log/sssd && chown sssd /var/log/sssd && gosu sssd /usr/sbin/sssd -d 0x0100 --logger=files -D &
    xrdp-sesman &
    gosu xrdp /usr/sbin/xrdp --nodaemon
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

add_perif_group() {
    for peripherique in /dev/dri/*; do
        if [ -e "$peripherique" ]; then
            # Récupérer le nom du groupe propriétaire du périphérique
            local nom_groupe=$(stat -c '%G' "$peripherique")
            if [ "$nom_groupe" = "UNKNOWN" ]; then
                # Si le nom du groupe est inconnu, utiliser le GID pour créer un nouveau groupe
                local gid=$(stat -c '%g' "$peripherique")
                nom_groupe="groupe_dri_$gid"
                # Créer le groupe si il n'existe pas déjà
                if ! grep -q "^$nom_groupe:" /etc/group; then
                    groupadd -g "$gid" "$nom_groupe"
                fi
            fi
            # Mettre à jour /etc/security/group.conf pour ajouter les utilisateurs à ce groupe lors de la connexion
            local group_conf_line="*;*;*;Al0000-24000;$nom_groupe"
            if ! grep -Fxq "$group_conf_line" /etc/security/group.conf; then
                echo "$group_conf_line" >> /etc/security/group.conf
            fi
        fi
    done
}

echo Entryponit script is Running...

add_perif_group &
mkdir -p /run/user && chmod 777 /run/user &

echo -e "starting xrdp services...\n"

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services