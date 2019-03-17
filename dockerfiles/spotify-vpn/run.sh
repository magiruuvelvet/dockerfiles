#!/usr/bin/bash

# prints to console in foreground for debugging
openvpn \
    --config "/vpn/client.ovpn" \
    --key "/vpn/client.key" \
    --cert "/vpn/client.crt" \
    --ca "/vpn/ca.crt" \
    --tls-auth "/vpn/ta.key" 1 &

# if home directory is empty, copy the backup
[ "$(ls -A /home/user)" ] || cp -avr /home/user.backup/. /home/user
[ "$(ls -A /root)" ] || cp -avr /home/root.backup/. /root

# run original entry point of container
exec /archlinux-extended.sh "$@"
