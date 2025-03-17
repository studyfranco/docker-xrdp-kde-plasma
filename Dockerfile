FROM debian:testing-slim
LABEL maintainer="studyfranco@hotmail.fr"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && rm /etc/apt/sources.list.d/debian.sources \
    && echo "deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && apt update \
    && apt install -y ca-certificates apt-transport-https --no-install-recommends \
    && echo "deb https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && apt update \
    && apt dist-upgrade -y \
    && echo "deb https://www.deb-multimedia.org testing main non-free" >> /etc/apt/sources.list.d/multimedia.list \
    && apt-get update -oAcquire::AllowInsecureRepositories=true \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated deb-multimedia-keyring --no-install-recommends \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential xrdp nano locales kwin-addons kwin-x11 kate pulseaudio dolphin htop net-tools tar wget curl pigz jq mpv vlc kde-plasma-desktop breeze krename gprename firefox-esr firefox-esr-l10n-fr mediainfo-gui mkvtoolnix mkvtoolnix-gui ffmpeg handbrake ldap-utils sssd libnss-sss libpam-sss sssd-tools mesa-utils mesa-va-drivers mesa-vulkan-drivers libgl1-mesa-dri libglx-mesa0 rsync xfonts-base fonts-noto-color-emoji --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y intel-media-va-driver \
    && apt dist-upgrade -y \
    && apt purge -yy xscreensaver light-locker \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/cache/apt \
    && rm -rf /var/log/* /var/tmp/* /tmp/*

# Configuration de la session KDE Plasma pour xrdp
RUN echo "startplasma-x11" > /etc/skel/.xsession && \
    cp /etc/skel/.xsession /root/

# Exposer le port xrdp
EXPOSE 3389

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
