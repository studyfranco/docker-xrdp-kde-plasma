FROM debian:testing-slim
LABEL maintainer="studyfranco@hotmail.fr"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && echo "deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/debian.sources \
    && apt update \
    && apt install -y ca-certificates \
    && apt dist-upgrade \
    && echo "deb https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/debian.sources \
    && echo "deb https://www.deb-multimedia.org testing main non-free" >> /etc/apt/sources.list.d/multimedia.list \
    && apt-get update -oAcquire::AllowInsecureRepositories=true \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated deb-multimedia-keyring \
    && apt update

RUN set -x \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y tar wget curl pigz jq mpv kde-plasma-desktop krename gprename xrdp firefox-esr firefox-esr-l10n-fr mediainfo mkvtoolnix mkvtoolnix-gui ffmpeg ldap-utils --no-install-recommends\
    && apt clean \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/log/*

# Configuration de la session KDE Plasma pour xrdp
RUN echo "startplasma-x11" > /etc/skel/.xsession && \
    cp /etc/skel/.xsession /root/

# Exposer le port xrdp
EXPOSE 3389

# Démarrage de xrdp en mode non-démon pour que le conteneur reste actif
CMD ["/usr/sbin/xrdp", "--nodaemon"]
