#!/bin/bash

# Ensure nftables service is active
systemctl enable --now nftables

# Accept loopback traffic
nft add rule inet filter input iif lo accept

# Drop spoofed 127/8 traffic on non-loopback
nft add rule inet filter input ip saddr 127.0.0.0/8 counter drop

# Drop spoofed IPv6 ::1 traffic on non-loopback (if IPv6 enabled)
if [ "$(cat /sys/module/ipv6/parameters/disable)" -eq 0 ]; then
    nft add rule inet filter input ip6 saddr ::1 counter drop
fi

# Save config permanently
nft list ruleset > /etc/nftables.conf
