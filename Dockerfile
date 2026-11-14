FROM ghcr.io/studyfranco/docker-baseimages-debian:testing as builder

# Install packages

ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux \
    && apt-get update \
    && apt-get -yy install sudo apt-utils git autoconf pkg-config libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex bison libxml2-dev dpkg-dev libcap-dev build-essential cdbs devscripts equivs fakeroot libxkbfile-dev libtool libltdl-dev gcc make automake libpipewire-0.3-dev libspa-0.2-dev --no-install-recommends

#    && apt dist-upgrade -y \ Is maybe useless

# Build xrdp

WORKDIR /tmp
RUN apt-get source pulseaudio xrdp
RUN apt-get build-dep -yy pulseaudio xrdp \
    && cd $(find . -maxdepth 1 -type d -name 'pulseaudio-*' | head -n 1) \
    && dpkg-buildpackage -rfakeroot -uc -b
WORKDIR /tmp
#RUN git clone --recursive https://github.com/neutrinolabs/xrdp.git
#WORKDIR /tmp/xrdp
#RUN ./bootstrap \
#    && ./configure CFLAGS="-O2 -Wno-error" \
#    && make \
#    && make install
WORKDIR /tmp
RUN  apt-get -y install libpulse-dev
RUN git clone --recursive https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
WORKDIR /tmp/pulseaudio-module-xrdp
RUN ./bootstrap \
    && ./configure --prefix=/usr PULSE_DIR=$(find /tmp -maxdepth 1 -type d -name 'pulseaudio-*[0-9]*' | head -n 1) \
    && make
RUN mkdir -p /tmp/so \
    && cp src/.libs/*.so /tmp/so \
    && cp /tmp/pulseaudio-module-xrdp/instfiles/pulseaudio-xrdp.desktop /tmp/so/ \
    && cp /tmp/pulseaudio-module-xrdp/instfiles/load_pa_modules.sh /tmp/so/
RUN make install

FROM ghcr.io/studyfranco/docker-xrdp-kde-plasma:master
LABEL maintainer="studyfranco@hotmail.fr"
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then sed -i 's|^path-exclude[=[:space:]]\+/usr/share/locale/\*|# &|' /etc/dpkg/dpkg.cfg.d/docker; fi \
    && apt-get update \
    && apt-get install -y xrdp kwin-addons kwin-x11 kwin-style-breeze kate dolphin dolphin-plugins kdegraphics-thumbnailers plasma-desktop plasma-workspace plasma-wallpapers-addons plasma-workspace-wallpapers plasma-browser-integration plasma-pa konsole kfind kdialog breeze breeze-gtk-theme breeze-cursor-theme krename kwalletmanager kglobalacceld plasma-runners-addons gprename xorgxrdp xutils x11-apps x11-xkb-utils dbus-x11 dbus-user-session xprintidle xloadimage xauth xdg-user-dirs xdg-utils plasma-systemmonitor systemsettings ark okular xsettings-kde kde-config-gtk-style kde-config-screenlocker kwayland-integration polkit-kde-agent-1 xdg-desktop-portal-kde kio-fuse kio-extras pulseaudio pulseaudio-module-gsettings --no-install-recommends \
    && apt-get remove --purge xscreensaver light-locker \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/* \
    && mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.old

# Installation des traductions Qt6 après l'environnement de bureau
RUN set -eux \
    && apt-get update \
    && apt-get install -y qt6-translations-l10n --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -eux \
    && apt-get update \
    && apt-get install -y kdenlive frei0r-plugins --no-install-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -eux \
    && apt-get update \
    && apt-get install -y firefox-esr firefox-esr-l10n-fr firefox-esr-l10n-de firefox-esr-l10n-ru mediainfo-gui mkvtoolnix-gui handbrake handbrake-gtk acetoneiso chromium chromium-driver chromium-sandbox --no-install-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -eux \
    && apt-get update \
    && apt-get install -y kompare --no-install-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -eux \
    && apt-get update \
    && aptitude install -y -o "Aptitude::ProblemResolver::SolutionCost=100*removed-packages, 200*canceled-actions, 50000" mpv --without-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -eux \
    && apt-get update \
    && aptitude install -y -o "Aptitude::ProblemResolver::SolutionCost=100*removed-packages, 200*canceled-actions, 50000" vlc --without-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && mkdir -p /var/lib/xrdp-pulseaudio-installer \
    && mkdir -p /usr/lib/pulse-compiled/modules \
    && mkdir -p /usr/libexec/pulseaudio-module-xrdp

COPY --from=builder /tmp/so/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-sink.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-source.so /usr/lib/pulse-compiled/modules
COPY --from=builder /tmp/so/module-xrdp-sink.so /usr/lib/pulse-compiled/modules

ADD --chmod=0755 wallpapers /usr/share/wallpapers
ADD --chmod=0755 etc/skel /etc/skel
ADD --chmod=0755 etc/xrdp /etc/xrdp
COPY --chmod=0644 etc/pam.d/xrdp-sesman /etc/pam.d/xrdp-sesman

COPY --chmod=0644 --from=builder /tmp/so/pulseaudio-xrdp.desktop /etc/xdg/autostart/
COPY --chmod=0755 --from=builder /tmp/so/load_pa_modules.sh /usr/libexec/pulseaudio-module-xrdp/

# Configuration de la session KDE Plasma pour xrdp et outil de redémarrage du presse-papiers
RUN printf '%s\n' '#!/bin/sh' 'pkill -u "$(id -u)" -x xrdp-chansrv >/dev/null 2>&1 || true' 'sleep 0.3' 'nohup /usr/sbin/xrdp-chansrv >/dev/null 2>&1 &' > /usr/local/bin/restart-xrdp-clipboard \
    && chmod 0755 /usr/local/bin/restart-xrdp-clipboard \
    && printf '%s\n' '[Desktop Entry]' 'Type=Application' 'Name=Restart xrdp clipboard' 'Name[fr]=Redémarrer le presse-papiers xrdp' 'Comment=Restart xrdp-chansrv when copy/paste stalls' 'Comment[fr]=Relance xrdp-chansrv si le copier-coller se bloque' 'Exec=/usr/local/bin/restart-xrdp-clipboard' 'Icon=edit-paste' 'Terminal=false' 'Categories=System;Utility;' > /usr/share/applications/restart-xrdp-clipboard.desktop \
    && chmod 0644 /usr/share/applications/restart-xrdp-clipboard.desktop \
    && echo "export XDG_RUNTIME_DIR=/run/user/\$(id -u)" >> /etc/skel/.bashrc \
    && cp /etc/skel/.bashrc /root/.bashrc \
    && sed -i "s/AllowRootLogin=true/AllowRootLogin=false/g;" /etc/xrdp/sesman.ini \
    && cp /usr/lib/pulse-compiled/modules/* $(find /usr/lib -maxdepth 1 -type d -name 'pulse*-*[0-9]*' | head -n 1)/modules \
    && echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config \
    && usermod -a -G ssl-cert xrdp \
    && echo "LANG=en_US.UTF-8\nLC_TIME=fr_FR.UTF-8" >> /etc/xrdp/sesman.ini

## This modifications create issues:
#    && sed -i "s/DisconnectedTimeLimit=0/DisconnectedTimeLimit=172800/g;" /etc/xrdp/sesman.ini \
#    && sed -i "s/IdleTimeLimit=0/IdleTimeLimit=172800/g;" /etc/xrdp/sesman.ini \
#    && sed -i "s/KillDisconnected=false/KillDisconnected=true/g;" /etc/xrdp/sesman.ini \

#RUN curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg \
#    && echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" > /etc/apt/sources.list.d/antigravity.list \
#    && set -x \
#    && apt update \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y antigravity

RUN set -eux \
    && apt-get update \
    && apt-get install -y extrepo --no-install-recommends \
    && extrepo enable vscodium \
    && apt-get update \
    && apt-get install -y codium --no-install-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN install -d -m 0755 /etc/apt/keyrings \
    && set -eux \
    && curl -fsSLo /etc/apt/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | tee /etc/apt/sources.list.d/claude-desktop.list \
    && apt-get update \
    && apt-get install -y claude-desktop --no-install-recommends \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN curl -fsSLo /tmp/goose_amd64.deb https://github.com/aaif-goose/goose/releases/download/v1.59.0/goose_1.59.0_amd64.deb \
    && dpkg -i /tmp/goose_amd64.deb \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
