#!/bin/bash
edit_dietpi_txt() {
  cat << EOF > /tmp/patch_dietpi_txt.sed
s/AUTO_SETUP_KEYBOARD_LAYOUT=gb/AUTO_SETUP_KEYBOARD_LAYOUT=us/
s/AUTO_SETUP_TIMEZONE=Europe\/London/AUTO_SETUP_TIMEZONE=Asia\/Taipei/
s/AUTO_SETUP_NET_ETHERNET_ENABLED=1/AUTO_SETUP_NET_ETHERNET_ENABLED=0/
s/AUTO_SETUP_NET_WIFI_ENABLED=0/AUTO_SETUP_NET_WIFI_ENABLED=1/
s/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=GB/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=TW/
s/AUTO_SETUP_AUTOMATED=0/AUTO_SETUP_AUTOMATED=1/
s/SURVEY_OPTED_IN=-1/SURVEY_OPTED_IN=0/
s/CONFIG_NTP_MIRROR=default/CONFIG_NTP_MIRROR=debian\.pool\.ntp\.org/
EOF
  sed -i -f /tmp/patch_dietpi_txt.sed /boot/dietpi.txt
}

if [ ! -e /boot/.gs0enabled ]; then
  # enable the USB serial device (available after reboot)
  echo dwc2 >> /etc/modules
  echo g_serial >> /etc/modules
  echo "dtoverlay=dwc2" >> /boot/config.txt
  edit_dietpi_txt
  # activate the serial console
  systemctl enable serial-getty@ttyGS0
  touch /boot/.gs0enabled
  # poweroff to indicate the finish of serial console setup
  # after reboot, the serial console is available
  poweroff
fi

