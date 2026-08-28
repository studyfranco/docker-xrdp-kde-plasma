FROM ghcr.io/studyfranco/docker-baseimages-debian:testing-video
LABEL maintainer="studyfranco@hotmail.fr"

# Exposer le port xrdp
EXPOSE 3389

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
    && rm -f /etc/dpkg/dpkg.cfg.d/excludes \
    && echo "de_DE.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8\nLC_MESSAGES=en_US.UTF-8\nLC_TIME=fr_FR.UTF-8\nLANGUAGE=" > /etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && locale-gen \
    && apt update \
    && apt dist-upgrade -y \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

# Essential software #
RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential jq rsync zip 7zip pkg-config openssl --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

# The essentials dev tools app #
RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y git openssh-client cargo rust-clippy rust-src rustfmt --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libchromaprint-tools --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y python3-dotenv python3-pydantic-settings python3-pip python3-psutil python3-venv --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN install -d -m 0755 /etc/apt/keyrings \
    && set -x \
    && curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" | tee /etc/apt/sources.list.d/claude-code.list \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y claude-code --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

# The auth app for ldap #
RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils sssd libnss-sss libpam-sss sssd-tools --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y fuse3 fuseiso file genisoimage udftools udfclient gdbm-l10n dbus-daemon --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y xfonts-base xfonts-cyrillic xfonts-scalable xfonts-intl-japanese xfonts-intl-japanese-big xfonts-intl-chinese xfonts-intl-european fonts-noto fonts-noto-extra fonts-noto-color-emoji fonts-arphic-ukai fonts-arphic-uming fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-ui-extra fonts-noto-unhinted fonts-hack fonts-lmodern fonts-freefont-otf fonts-stix fonts-texgyre fonts-texgyre-math fonts-noto-ui-core fonts-liberation --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*

RUN set -x \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y handbrake-cli ffmpegthumbs --no-install-recommends --fix-missing \
    && apt autopurge -yy \
    && apt clean \
    && rm -rf /var/cache/* /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*