#!/bin/bash
apt install -y dhcpcd5
apt purge -y isc-dhcp-client
cat << EOF >> /etc/dhcpcd.conf

# configure usb0 to use the default link-local address
interface usb0
# Try to get this specific address first
static ip_address=169.254.1.1/16
# If that fails or if a DHCP server is present, fall back
ipv4ll
EOF

# poweroff to indicate end of installation
poweroff
