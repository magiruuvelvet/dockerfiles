# docker build --rm --no-cache -t magiruuvelvet/archlinux-extended .
# docker run --privileged -e PULSEAUDIO_IP=172.17.0.1 -v /docker/volumes/archlinux:/data --rm -it magiruuvelvet/archlinux-extended
# docker run --privileged -e PULSEAUDIO_IP=172.17.0.1 -v /docker/volumes/archlinux:/data -d magiruuvelvet/archlinux-extended

# additional docker run arguments:
# openvpn:   --cap-add=NET_ADMIN --device=/dev/net/tun
# alsa:      --device=/dev/snd
# i3status:  --privileged (yes i3status needs /dev access and other things on the host)

# pulseaudio config on host machine:
# load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;172.17.0.0/16;172.18.0.0/16

# environment variables when running container:
#  > PULSEAUDIO_IP      address of your docker subnet (example: 172.17.0.1)

# sound was tested and actually works

FROM archlinux/base:latest

# create locales
RUN echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=ja_JP.UTF-8" >> /etc/locale.conf
RUN locale-gen
ENV LANG="ja_JP.UTF-8"

# copy launcher
COPY run.sh /archlinux-extended.sh
RUN chmod +x /archlinux-extended.sh

# update system and install software
RUN pacman -Syyu coreutils \
    iputils bind-tools procps-ng sudo git grep which awk nano wget fakeroot \
    openvpn mesa mesa-demos xorg-server libglvnd tigervnc xorg-xinit xorg-xrdb xorg-xsetroot \
    i3-wm i3status i3lock \
    pulseaudio libpulse pulseaudio-alsa alsa-lib alsa-plugins alsa-tools alsa-utils \
    fcitx kcm-fcitx fcitx-mozc fcitx-gtk2 fcitx-gtk3 fcitx-qt5 \
    konsole phonon-qt5-gstreamer dbus mpv \
    fontconfig noto-fonts noto-fonts-cjk noto-fonts-emoji wqy-microhei wqy-microhei-lite wqy-zenhei \
    electron gconf libxss rtmpdump openssl-1.0 libcurl-gnutls \
    clang \
    --noconfirm

# generate machine-id file
RUN dbus-uuidgen > /etc/machine-id

# install yay
RUN mkdir -p /tmp
RUN wget https://github.com/Jguer/yay/releases/download/v9.1.0/yay_9.1.0_x86_64.tar.gz -O /tmp/yay.tar.gz
RUN \
    tar xvf /tmp/yay.tar.gz -C /tmp yay_9.1.0_x86_64/yay && \
    mv /tmp/yay_9.1.0_x86_64/yay /usr/bin/ && \
    rm -rf /tmp/yay_9.1.0_x86_64/ && \
    rm -rf /tmp/yay.tar.gz

# create unprivileged user
RUN useradd -m -G root -s /usr/bin/bash user

# copy i3 config
RUN mkdir -p /root/.config/i3
COPY i3.config /root/.config/i3/config

RUN mkdir -p /home/user/.config/i3
COPY i3.config /home/user/.config/i3/config
RUN chown -R user:user /home/user

# copy headless X11 config
RUN mkdir -p /etc/X11/xorg.conf.d
COPY xorg-headless.conf /etc/X11/xorg.conf.d/10-headless.conf

# copy VNC config
RUN mkdir -p /root/.vnc
COPY xstartup /root/.vnc/xstartup
COPY xvnc.config /root/.vnc/config
RUN chmod +x /root/.vnc/xstartup

# expose VNC ports
EXPOSE 5900 5800

# shared data volume
RUN mkdir -p /data
VOLUME /data

# run container with automatic setup
ENTRYPOINT ["/archlinux-extended.sh"]
