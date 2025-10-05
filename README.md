# Docker xRDP + KDE Plasma Remote Desktop Container

[![GitHub stars](https://badgen.net/github/stars/studyfranco/docker-xrdp-kde-plasma?icon=github&label=stars)](https://github.com/studyfranco/docker-xrdp-kde-plasma/stargazers)  
[![GitHub forks](https://badgen.net/github/forks/studyfranco/docker-xrdp-kde-plasma?icon=github&label=forks)](https://github.com/studyfranco/docker-xrdp-kde-plasma/network)  
[![GitHub issues](https://badgen.net/github/issues/studyfranco/docker-xrdp-kde-plasma?icon=github&label=issues)](https://github.com/studyfranco/docker-xrdp-kde-plasma/issues)  
[![GitHub last-commit](https://badgen.net/github/last-commit/studyfranco/docker-xrdp-kde-plasma)](https://github.com/studyfranco/docker-xrdp-kde-plasma/commits/master)

## Overview

This repository provides a ready‑to‑run Docker container that serves a full KDE Plasma desktop over RDP via **xRDP**, built on top of [studyfranco/docker-baseimages-debian](https://github.com/studyfranco/docker-baseimages-debian). It bundles:

- The latest **KDE Plasma** desktop environment  
- **xRDP** server with session management  
- **PulseAudio** modules for seamless sound over RDP  
- A curated selection of KDE apps (Dolphin, Konsole, Okular, Kate, etc.)  
- Preconfigured locales, fonts, wallpapers, and session scripts  

Perfect for headless servers where you need a GUI accessible from any RDP client.

## Features

- **Multiple Locales**: en_US, fr_FR, de_DE, ru_RU UTF‑8 support  
- **Sound over RDP** via PulseAudio and `pulseaudio-module-xrdp`  
- **Hardware acceleration** support (VA‑API, Vulkan, OpenCL)  
- **Preloaded KDE utilities**: Dolphin, Kate, Okular, VLC, MPV, HandBrake, mkvtoolnix, etc.  
- **Custom `.xsession`** for seamless Plasma startup  
- **Secure defaults**: non‑root login only, session timeouts, cleaned caches  
- **Lightweight base**: built on Debian Testing slim image  

## Usage

You can run the container standalone or via Docker Compose. Below is an example `docker-compose.yml`:

```yaml
services:
  xrdp-kde-plasma:
    container_name: xrdp-kde-plasma
    hostname: xrdp-kde-plasma
    image: ghcr.io/studyfranco/docker-xrdp-kde-plasma:pulseaudio
    expose:
      - 3389/tcp
    ports:
      - "3389:3389"
    environment:
      TZ: Europe/Berlin
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /path/to/home:/home/user
    tmpfs:
      - "/run:exec,mode=777"
      - "/tmp:exec,mode=777"
      - "/tmp/dumps:exec,mode=777"
      - "/var/tmp:exec,mode=777"
    restart: "unless-stopped"
    devices:
      - /dev/dri:/dev/dri
    group_add:
      - video
      - render
    restart: unless-stopped
```

---

## Configuration

### Environment Variables

| Variable | Default        | Description                              |
| -------- | -------------- | ---------------------------------------- |
| `TZ`     | `Europe/Paris` | Timezone (e.g. `America/New_York`)       |

### Volumes & Ports

- **Ports**  
  - `3389`: RDP port  

- **Volumes**  
  - `/etc/localtime:/etc/localtime:ro` → sync host time  
  - `/path/to/home:/home/user` → user home directory  

- **Devices**  
  - `/dev/dri:/dev/dri` → pass through GPU for acceleration  

## License

This project is licensed under the GNU Affero General Public License v3.0. See the [LICENSE](LICENSE) file for details.

---

For more information and updates, visit the [GitHub Repository](https://github.com/studyfranco/docker-xrdp-kde-plasma).

## Last Update

2025/10/05
