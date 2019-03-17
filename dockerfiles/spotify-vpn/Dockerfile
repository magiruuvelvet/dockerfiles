# docker build --rm --no-cache -t magiruuvelvet/spotify-vpn .
# docker run --privileged -e PULSEAUDIO_IP=172.17.0.1 -v /docker/volumes/archlinux:/data --rm -it magiruuvelvet/spotify-vpn bash
# docker run --privileged -e PULSEAUDIO_IP=172.17.0.1 -v /docker/volumes/archlinux:/data -d magiruuvelvet/spotify-vpn

# docker run --privileged --net docker1 --ip 172.18.5.2 -e PULSEAUDIO_IP=172.18.0.1 -v /docker/volumes/spotify/data:/data -v /docker/volumes/spotify/home:/home/user -v /docker/volumes/spotify/root:/root --name spotify-vpn -d magiruuvelvet/spotify-vpn

FROM magiruuvelvet/archlinux-extended:latest

# copy VPN profile
RUN mkdir -p /vpn
COPY run.sh ca.crt client.crt client.key client.ovpn ta.key /vpn/
RUN chmod +x /vpn/run.sh

# backup home directory
RUN cp -avr /home/user/ /home/user.backup
RUN cp -avr /root/ /home/root.backup

# update software
RUN pacman -Syyu

# install spotify
USER user
RUN cd /tmp && git clone https://aur.archlinux.org/spotify.git
RUN cd /tmp/spotify && PKGEXT=.pkg.tar makepkg --nocheck --skipchecksums --skippgpcheck --noprepare
USER root
RUN cd /tmp/spotify && pacman -U --noconfirm spotify-1:1.0.98.78-2-x86_64.pkg.tar
RUN rm -rf /tmp/spotify

# persistent home storage
VOLUME /home/user
VOLUME /root

ENTRYPOINT ["/vpn/run.sh"]
