# Arch Linux [Extended Docker Image]

 - X11 VNC access
 - i3 window manager
 - fcitx
 - D-Bus
 - OpenVPN
 - sound with pulseaudio (see Dockerfile comments)
 - yay AUR helper
 - clang compiler

Language is configured to Japanese inside the container.

For more information see the Dockerfile comments.

**This image is an experiment to learn more about Docker and
its capabilities.**

A volume is mounted at `/data` for persistent storage.

Exposed ports are `5900` and `5800` (TigerVNC).

 - `docker run ... magiruuvelvet/archlinux-extended` without additional
   arguments will always start the VNC server and i3.
 - If you want to run, for example bash, pass additional run arguments
   to the container. (`magiruuvelvet/archlinux-extended bash`)

**NOTE:** I'm using this image as a base for other stuff and
experiments, so I don't need to download everything over and
over again and speed up subsequent Dockerfile builds, which
inherit from this image.

The overall final size of the image is 3GB.
