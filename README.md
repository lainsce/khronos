<img align="left" style="vertical-align: middle" width="120" height="120" src="data/icon.png">
 
# Khronos

Track each task's time in a simple inobtrusive way

###

[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

<a href="https://circle.gnome.org/"><img height='80' alt='Part of GNOME Circle' src='https://gitlab.gnome.org/Teams/Circle/-/raw/91de93edbb3e75eb0882d56bd466e58b525135d5/assets/button/circle-button-fullcolor.svg'/>

![Screenshot](data/shot.png)

<p align="center"><a href='https://flathub.org/apps/details/io.github.lainsce.Khronos'><img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a></p>

## 💝 Donations

Would you like to support the development of this app to new heights? Then:

[Be my backer on Patreon](https://www.patreon.com/lainsce)

## 🛠️ Dependencies

Please make sure you have these dependencies first before building.

```bash
gtk4
libadwaita-1
libgee-0.8
libjson-glib
meson
vala
```

## 🏗️ Building

Simply clone this repo, then:

```bash
meson _build --prefix=/usr && cd _build
sudo ninja install
```
