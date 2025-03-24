FROM debian:testing-slim as builder

# Install packages

ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
    && rm /etc/apt/sources.list.d/debian.sources \
    && echo "deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && apt update \
    && apt install -y ca-certificates apt-transport-https --no-install-recommends \
    && echo "deb https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && apt update \
    && apt dist-upgrade -y
RUN apt-get -yy install sudo apt-utils git autoconf pkg-config libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex bison libxml2-dev dpkg-dev libcap-dev build-essential cdbs devscripts equivs fakeroot libxkbfile-dev libtool libltdl-dev gcc make automake libpipewire-0.3-dev libspa-0.2-dev

# Build xrdp

WORKDIR /tmp
RUN apt-get source pulseaudio
RUN apt-get build-dep -yy pulseaudio xrdp \
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
RUN ./bootstrap && ./configure PULSE_DIR=$(find /tmp -maxdepth 1 -type d -name 'pulseaudio-*[0-9]*' | head -n 1)
RUN make
RUN mkdir -p /tmp/so \
    && cp src/.libs/*.so /tmp/so \
    && cp /tmp/pulseaudio-module-xrdp/instfiles/pulseaudio-xrdp.desktop /tmp/so/ \
    && cp /tmp/pulseaudio-module-xrdp/instfiles/load_pa_modules.sh /tmp/so/
RUN make install

FROM debian:testing-slim
LABEL maintainer="studyfranco@hotmail.fr"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE= \
    LC_ADDRESS=fr_FR.UTF-8 \
    LC_IDENTIFICATION=fr_FR.UTF-8 \
    LC_MEASUREMENT=fr_FR.UTF-8 \
    LC_MONETARY=fr_FR.UTF-8 \
    LC_NAME=fr_FR.UTF-8 \
    LC_NUMERIC=fr_FR.UTF-8 \
    LC_PAPER=fr_FR.UTF-8 \
    LC_TELEPHONE=fr_FR.UTF-8 \
    LC_TIME=fr_FR.UTF-8

RUN set -x \
    && rm /etc/apt/sources.list.d/debian.sources \
    && echo "Acquire::Languages { \"fr\"; \"de\"; \"ru\"; \"en\";};" > /etc/apt/apt.conf.d/docker-no-languages \
    && echo "deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && apt update \
    && apt install -y ca-certificates apt-transport-https --no-install-recommends \
    && echo "deb https://deb.debian.org/debian/ testing main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb https://deb.debian.org/debian/ unstable main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && echo "Package: *\nPin: release a=unstable\nPin-Priority: 490" > /etc/apt/preferences.d/list \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
    && echo "C.UTF-8 UTF-8\nde_DE.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8\nLC_MESSAGES=en_US.UTF-8\nLANGUAGE=" > /etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && locale-gen \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales-all \
    && apt dist-upgrade -y \
    && echo "deb https://www.deb-multimedia.org testing main non-free" >> /etc/apt/sources.list.d/multimedia.list \
    && apt-get update -oAcquire::AllowInsecureRepositories=true \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated deb-multimedia-keyring --no-install-recommends \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential xrdp nano less kwin-addons kwin-x11 kate pulseaudio dolphin dolphin-plugins ffmpegthumbs kdegraphics-thumbnailers htop net-tools tar wget curl pigz jq mpv vlc plasma-desktop plasma-workspace plasma-wallpapers-addons plasma-workspace-wallpapers plasma-browser-integration plasma-pa konsole kfind kdialog breeze breeze-gtk-theme breeze-cursor-theme *breeze*qt* krename kwalletmanager plasma-runners-addons gprename firefox-esr firefox-esr-l10n-fr firefox-esr-l10n-de firefox-esr-l10n-ru mediainfo-gui mkvtoolnix mkvtoolnix-gui ffmpeg handbrake handbrake-cli handbrake-gtk ldap-utils sssd libnss-sss libpam-sss sssd-tools mesa-utils mesa-va-drivers mesa-vulkan-drivers mesa-opencl-icd libgl1-mesa-dri libglx-mesa0 vulkan-tools rsync xfonts-base xfonts-cyrillic xfonts-scalable xfonts-intl-japanese xfonts-intl-japanese-big xfonts-intl-chinese xfonts-intl-european fonts-noto fonts-noto-extra fonts-noto-color-emoji fonts-arphic-ukai fonts-arphic-uming fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-ui-extra fonts-noto-unhinted xorgxrdp xutils x11-apps dbus-x11 dbus-user-session xprintidle xauth xdg-user-dirs xdg-utils 7zip bash-completion plasma-systemmonitor systemsettings zip acl ark sed okular pkg-config pulseaudio-module-gsettings vainfo xsettings-kde kde-config-gtk-style kde-config-screenlocker kwayland-integration intel-media-va-driver-non-free firmware-intel-graphics firmware-intel-misc intel-opencl-icd gdbm-l10n qt*-translations-l10n qttranslations*-l10n vim gosu --no-install-recommends \
    && apt purge -yy xscreensaver light-locker sudo \
    && apt dist-upgrade -y \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/* \
    && mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.old \
    && mkdir -p /var/lib/xrdp-pulseaudio-installer \
    && mkdir -p /usr/lib/pulse-compiled/modules \
    && mkdir -p /usr/local/libexec/pulseaudio-module-xrdp
COPY --from=builder /tmp/so/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-sink.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-source.so /usr/lib/pulse-compiled/modules
COPY --from=builder /tmp/so/module-xrdp-sink.so /usr/lib/pulse-compiled/modules

ADD --chmod=0755 wallpapers /usr/share/wallpapers
ADD --chmod=0755 etc/skel /etc/skel
ADD --chmod=0755 etc/xrdp /etc/xrdp

RUN mkdir -p /usr/libexec/pulseaudio-module-xrdp \
    && wget -O- https://raw.githubusercontent.com/neutrinolabs/pulseaudio-module-xrdp/refs/heads/devel/instfiles/load_pa_modules.sh | tee /usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh \
    && chmod +x /usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh \
    && wget -O- https://raw.githubusercontent.com/neutrinolabs/pulseaudio-module-xrdp/refs/heads/devel/instfiles/pulseaudio-xrdp.desktop.in | tee /etc/xdg/autostart/pulseaudio-xrdp.desktop

COPY --from=builder /tmp/so/pulseaudio-xrdp.desktop /etc/xdg/autostart
COPY --from=builder /tmp/so/load_pa_modules.sh /usr/libexec/pulseaudio-module-xrdp

# Configuration de la session KDE Plasma pour xrdp
RUN echo "xdg-user-dirs-update &\nmkdir -p /run/user/\$(id -u) && chmod 700 /run/user/\$(id -u)\nexport XDG_RUNTIME_DIR=/run/user/\$(id -u)\npulseaudio --start &\nstartplasma-x11" > /etc/skel/.xsession \
    && cp /etc/skel/.xsession /root/ \
    && echo "export XDG_RUNTIME_DIR=/run/user/\$(id -u)" >> /etc/skel/.bashrc \
    && cp /etc/skel/.bashrc /root/.bashrc \
    && sed -i "s/AllowRootLogin=true/AllowRootLogin=false/g;" /etc/xrdp/sesman.ini \
    && sed -i "s/KillDisconnected=false/KillDisconnected=true/g;" /etc/xrdp/sesman.ini \
    && sed -i "s/DisconnectedTimeLimit=0/DisconnectedTimeLimit=172800/g;" /etc/xrdp/sesman.ini \
    && sed -i "s/IdleTimeLimit=0/IdleTimeLimit=172800/g;" /etc/xrdp/sesman.ini \
    && cp /usr/lib/pulse-compiled/modules/* $(find /usr/lib -maxdepth 1 -type d -name 'pulse*-*[0-9]*' | head -n 1)/modules

# Exposer le port xrdp
EXPOSE 3389

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
