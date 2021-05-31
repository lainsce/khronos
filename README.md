# ![icon](data/icon.png) Khronos

## Track each task's time in a simple inobtrusive way

<a href='https://flathub.org/apps/details/io.github.lainsce.Khronos'><img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>
<a href="https://circle.gnome.org/"><img height='80' alt='Part of GNOME Circle' src='https://gitlab.gnome.org/Teams/Circle/-/raw/91de93edbb3e75eb0882d56bd466e58b525135d5/assets/button/circle-button-fullcolor.svg'/>

[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

![Screenshot](data/shot.png)

## Donations

Would you like to support the development of this app to new heights? Then:

[Be my backer on Patreon](https://www.patreon.com/lainsce)

## Dependencies

Please make sure you have these dependencies first before building.

```bash
gtk+-3.0
libhandy-1
meson
```

## Building

Simply clone this repo, then:

```bash
meson build --prefix=/usr && cd build
sudo ninja install
```
