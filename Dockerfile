FROM ghcr.io/studyfranco/docker-xrdp-kde-plasma:master
LABEL maintainer="studyfranco@hotmail.fr"

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y xrdp kwin-addons kwin-x11 kwin-style-breeze kate dolphin dolphin-plugins kdegraphics-thumbnailers plasma-desktop plasma-workspace plasma-wallpapers-addons plasma-workspace-wallpapers plasma-browser-integration plasma-pa konsole kfind kdialog breeze breeze-gtk-theme breeze-cursor-theme krename kwalletmanager plasma-runners-addons kglobalacceld gprename xorgxrdp xutils x11-apps dbus-x11 dbus-user-session xprintidle xloadimage xauth xdg-user-dirs xdg-utils plasma-systemmonitor systemsettings ark okular xsettings-kde kde-config-gtk-style kde-config-screenlocker kwayland-integration polkit-kde-agent-1 xdg-desktop-portal-kde udisks2 pipewire-module-xrdp pipewire-audio pipewire pipewire-pulse wireplumber at-spi2-core gstreamer1.0-pipewire kio-fuse kio-extras --no-install-recommends --fix-missing \
    && apt purge -yy xscreensaver light-locker \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/* \
    && mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.old

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y kdenlive frei0r-plugins --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y firefox-esr firefox-esr-l10n-fr firefox-esr-l10n-de firefox-esr-l10n-ru mediainfo-gui mkvtoolnix-gui handbrake handbrake-gtk acetoneiso chromium chromium-driver chromium-sandbox --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive aptitude install -y -o "Aptitude::ProblemResolver::SolutionCost=100*removed-packages, 200*canceled-actions, 50000" mpv --without-recommends \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive aptitude install -y -o "Aptitude::ProblemResolver::SolutionCost=100*removed-packages, 200*canceled-actions, 50000" vlc --without-recommends \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

ADD --chmod=0755 wallpapers /usr/share/wallpapers
ADD --chmod=0755 etc/skel /etc/skel
ADD --chmod=0755 etc/xrdp /etc/xrdp
COPY --chmod=0644 etc/pam.d/xrdp-sesman /etc/pam.d/xrdp-sesman

# Configuration de la session KDE Plasma pour xrdp
RUN echo "xdg-user-dirs-update &\n. /etc/default/locale\nmkdir -p /run/user/\$(id -u) && chmod 700 /run/user/\$(id -u)\nexport XDG_RUNTIME_DIR=/run/user/\$(id -u)\nrm -rf /run/user/\$(id -u)/*\nexec dbus-launch --exit-with-session /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 &\nexec dbus-launch --exit-with-session pipewire &\nexec dbus-launch --exit-with-session wireplumber &\nexec dbus-launch --exit-with-session pipewire-pulse &\nxset s off && xset s noblank && xset -dpms\nexec dbus-launch --exit-with-session startplasma-x11" > /etc/skel/.xsession \
    && cp /etc/skel/.xsession /root/ \
    && echo "export XDG_RUNTIME_DIR=/run/user/\$(id -u)" >> /etc/skel/.bashrc \
    && cp /etc/skel/.bashrc /root/.bashrc \
    && sed -i "s/AllowRootLogin=true/AllowRootLogin=false/g;" /etc/xrdp/sesman.ini \
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


RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y extrepo --no-install-recommends --fix-missing \
    && extrepo enable vscodium \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y codium --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN install -d -m 0755 /etc/apt/keyrings \
    && set -x \
    && curl -fsSLo /etc/apt/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | tee /etc/apt/sources.list.d/claude-desktop.list \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y claude-desktop --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
