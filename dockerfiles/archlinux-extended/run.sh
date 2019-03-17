#!/usr/bin/bash

# update pulseaudio config to use the host machine ip address
if [ ! -z "$PULSEAUDIO_IP" ]; then
    if ! grep -q "$PULSEAUDIO_IP" /etc/pulse/client.conf; then
        echo "setting pulseaudio server address to $PULSEAUDIO_IP..."
        echo "default-server = $PULSEAUDIO_IP" >> /etc/pulse/client.conf
    else
        echo "pulseaudio server address already set to $PULSEAUDIO_IP"
    fi
fi

# start VNC if no arguments given
if [ $# -eq 0 ]; then

    # remove old X11 locks to make container restarts work
    rm -rf /tmp/.X0-lock
    rm -rf /tmp/.X11-unix/X0

    # run VNC server, connect with KRDC
    vncserver :0 &

    # wait
    sleep 6

    # run i3
    DISPLAY=:0 i3

    # container should stop after i3 exits

# start given command otherwise
else

    exec "$@"

fi
