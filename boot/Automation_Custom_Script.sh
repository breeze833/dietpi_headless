#!/bin/bash
apt install -y dhcpcd5 arping
apt purge -y isc-dhcp-client
cat << EOF >> /etc/dhcpcd.conf

# Try set IP from DHCP and fallback to IPv4LL
# Put to background to reduce the boot delay
interface usb0
background
timeout 3

EOF

cat << EOF >> /usr/lib/dhcpcd/dhcpcd-hooks/99-usb0-llip.conf

#!/bin/sh

# This hook triggers after dhcpcd transitions into the IPV4LL state
if [ "\$interface" = "usb0" ] && [ "\$reason" = "IPV4LL" ]; then
    PREFERRED_IP="169.254.1.1"

    # Dynamically find the actual Link-Local IP currently bound to usb0
    CURRENT_LL_IP=\$(ip -4 addr show dev usb0 | awk '/inet / {print \$2}' | cut -d/ -f1)

    # If the interface hasn't successfully bound an LL IP yet, skip
    if [ -z "\$CURRENT_LL_IP" ]; then
        exit 0
    fi

    # Quick sanity check: If we are already 169.254.1.1, do nothing.
    if [ "\$CURRENT_LL_IP" = "\$PREFERRED_IP" ]; then
        exit 0
    fi

    # Run Duplicate Address Detection (DAD) on our preferred IP
    # -c 2 sends 2 probes, -w 1 times out after 1 second
    if ! arping -c 2 -w 1 -D -I usb0 "\$PREFERRED_IP" >/dev/null 2>&1; then
        logger -t dhcpcd-hook "usb0: \$PREFERRED_IP is clear. Promoting it to be the primary IP instead of \$CURRENT_LL_IP."
        
        # 1. Add our preferred IP to the interface
        ip addr add "\$PREFERRED_IP/16" dev usb0 broadcast 169.254.255.255
        
        # 2. To ensure the kernel defaults to 169.254.1.1 over dhcpcd's auto IP
        # Simply deleting the old one would trigger dhcpcd to determine an IP again
        ip route replace 169.254.0.0/16 dev usb0 src "\$PREFERRED_IP" scope link
        
    else
        logger -t dhcpcd-hook "usb0: Conflict detected! Keeping default IPV4LL (\$CURRENT_LL_IP)."
    fi
fi

EOF

# poweroff to indicate end of installation
poweroff
