#!/bin/bash
edit_dietpi_txt() {
  cat << EOF > /tmp/patch_dietpi_txt.sed
s/AUTO_SETUP_KEYBOARD_LAYOUT=.*/AUTO_SETUP_KEYBOARD_LAYOUT=us/
s/AUTO_SETUP_TIMEZONE=.*/AUTO_SETUP_TIMEZONE=Asia\/Taipei/
s/AUTO_SETUP_NET_ETHERNET_ENABLED=1/AUTO_SETUP_NET_ETHERNET_ENABLED=0/
s/AUTO_SETUP_NET_WIFI_ENABLED=0/AUTO_SETUP_NET_WIFI_ENABLED=1/
s/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=.*/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=TW/
s/AUTO_SETUP_AUTOMATED=0/AUTO_SETUP_AUTOMATED=1/
s/SURVEY_OPTED_IN=-1/SURVEY_OPTED_IN=0/
s/CONFIG_NTP_MIRROR=.*/CONFIG_NTP_MIRROR=debian\.pool\.ntp\.org/
EOF
  sed -i -f /tmp/patch_dietpi_txt.sed /boot/dietpi.txt
}

enable_usb_gadget_script() {
  cat << EOF > /usr/local/bin/usb-gadget.sh
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p g1
cd g1

# 1. Identity
echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice
echo 0x0200 > bcdUSB
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol

mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Raspberry Pi" > strings/0x409/manufacturer
echo "PiZero Multi-Gadget" > strings/0x409/product

# 2. Configurations
mkdir -p configs/c.1/strings/0x409
echo "Config 1: Serial, Net, Storage" > configs/c.1/strings/0x409/configuration
echo 0xc0 > configs/c.1/bmAttributes # Self-powered + Remote Wakeup
echo 500 > configs/c.1/MaxPower

# --- FUNCTION 1: Serial (ACM) ---
mkdir -p functions/acm.usb0
ln -s functions/acm.usb0 configs/c.1/

# --- FUNCTION 2: Ethernet (NCM) ---      
# NCM is the newer standard for Windows/Linux/MacOS                            
mkdir -p functions/ncm.usb0  
# Set MAC addresses (Fixed addresses prevent "New Network Found" prompts)
# Use a locally administered address (the first byte ends in 2, 6, A, or E)
echo "02:22:33:44:55:66" > functions/ncm.usb0/host_addr  
echo "02:22:33:44:55:67" > functions/ncm.usb0/dev_addr  
ln -s functions/ncm.usb0 configs/c.1/

# --- FUNCTION 3: Mass Storage ---
FILE=/var/lib/usb_storage.bin
if [ -e \$FILE ]; then
  mkdir -p functions/mass_storage.usb0
  echo 1 > functions/mass_storage.usb0/stall
  echo \$FILE > functions/mass_storage.usb0/lun.0/file
  echo 1 > functions/mass_storage.usb0/lun.0/removable
  echo 0 > functions/mass_storage.usb0/lun.0/ro
  ln -s functions/mass_storage.usb0 configs/c.1/
fi

# 3. Enable
ls /sys/class/udc > UDC

# 4. access from gadget side to wakeup the host side (tricky)
echo -e "\\n\\n" > /dev/ttyGS0
EOF

cat << EOF > /etc/systemd/system/usb-gadget.service
[Unit]
Description=Configure USB Composite Gadget
Before=serial-getty@ttyGS0.service
After=local-fs.target

[Service]
Type=oneshot
# This line forces the kernel to load libcomposite before running ExecStart
ExecStartPre=/sbin/modprobe libcomposite
ExecStart=/usr/local/bin/usb-gadget.sh
# Ensures the script stays "active" in systemd's eyes
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
RequiredBy=serial-getty@ttyGS0.service
EOF
  chmod +x /usr/local/bin/usb-gadget.sh
}

if [ ! -e /boot/.gs0enabled ]; then
  # enable the USB composite device (available after reboot)
  echo dwc2 >> /etc/modules
  echo libcomposite >> /etc/modules
  echo "dtoverlay=dwc2" >> /boot/config.txt
  edit_dietpi_txt
  enable_usb_gadget_script
  # activate the USB composite gadget
  systemctl enable usb-gadget.service
  # activate the serial console
  systemctl enable serial-getty@ttyGS0
  touch /boot/.gs0enabled
  # poweroff to indicate the finish of serial console setup
  # after reboot, the serial console is available
  poweroff
fi

