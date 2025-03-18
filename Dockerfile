FROM debian:testing-slim as builder

# Install packages

ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && rm /etc/apt/sources.list.d/debian.sources \
    && echo "deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && apt update \
    && apt install -y ca-certificates apt-transport-https --no-install-recommends \
    && echo "deb https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && apt update \
    && apt dist-upgrade -y
RUN apt-get -yy install sudo apt-utils git autoconf pkg-config libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex bison libxml2-dev dpkg-dev libcap-dev build-essential cdbs devscripts equivs fakeroot libxkbfile-dev
#software-properties-common

# Build xrdp

WORKDIR /tmp
RUN apt-get source pulseaudio
RUN apt-get build-dep -yy pulseaudio \
    && cd $(find . -maxdepth 1 -type d -name 'pulseaudio-*' | head -n 1) \
    && dpkg-buildpackage -rfakeroot -uc -b
WORKDIR /tmp
RUN git clone --recursive https://github.com/neutrinolabs/xrdp.git
WORKDIR /tmp/xrdp
RUN ./bootstrap
RUN ./configure
RUN make
RUN make install
WORKDIR /tmp
RUN  apt -yy install libpulse-dev
RUN git clone --recursive https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
WORKDIR /tmp/pulseaudio-module-xrdp
RUN ./bootstrap && ./configure PULSE_DIR=/tmp/$(find /tmp -maxdepth 1 -type d -name 'pulseaudio-*' | head -n 1)
RUN make
RUN mkdir -p /tmp/so \
    && cp src/.libs/*.so /tmp/so

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
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential xrdp nano locales kwin-addons kwin-x11 kate pulseaudio dolphin dolphin-plugins ffmpegthumbs kdegraphics-thumbnailers htop net-tools tar wget curl pigz jq mpv vlc plasma-desktop plasma-workspace plasma-wallpapers-addons plasma-workspace-wallpapers plasma-browser-integration konsole kfind kdialog breeze breeze-gtk-theme krename kwalletmanager plasma-runners-addons gprename firefox-esr firefox-esr-l10n-fr mediainfo-gui mkvtoolnix mkvtoolnix-gui ffmpeg handbrake ldap-utils sssd libnss-sss libpam-sss sssd-tools mesa-utils mesa-va-drivers mesa-vulkan-drivers libgl1-mesa-dri libglx-mesa0 rsync xfonts-base fonts-noto-color-emoji xorgxrdp dbus-x11 7zip bash-completion plasma-systemmonitor systemsettings zip acl ark sed okular --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y intel-media-va-driver \
    && apt dist-upgrade -y \
    && apt purge -yy xscreensaver light-locker \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/cache/apt \
    && rm -rf /var/log/* /var/tmp/* /tmp/* \
    && mkdir -p /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-sink.so /var/lib/xrdp-pulseaudio-installer
#ADD bin /usr/bin
#ADD etc /etc
    
# Configure
#RUN cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
#    sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
#    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
#    locale-gen en_US.UTF-8 && \
#    echo "xfce4-session" > /etc/skel/.Xclients && \
#    rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem

# Configuration de la session KDE Plasma pour xrdp
RUN echo "startplasma-x11" > /etc/skel/.xsession && \
    cp /etc/skel/.xsession /root/

# Exposer le port xrdp
EXPOSE 3389

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
