#!/bin/bash
edit_dietpi_txt() {
  cat << EOF > /tmp/patch_dietpi_txt.sed
s/AUTO_SETUP_KEYBOARD_LAYOUT=gb/AUTO_SETUP_KEYBOARD_LAYOUT=us/
s/AUTO_SETUP_TIMEZONE=Europe\/London/AUTO_SETUP_TIMEZONE=Asia\/Taipei/
s/AUTO_SETUP_NET_ETHERNET_ENABLED=1/AUTO_SETUP_NET_ETHERNET_ENABLED=0/
s/AUTO_SETUP_NET_WIFI_ENABLED=0/AUTO_SETUP_NET_WIFI_ENABLED=1/
s/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=GB/AUTO_SETUP_NET_WIFI_COUNTRY_CODE=TW/
s/AUTO_SETUP_BOOT_WAIT_FOR_NETWORK=1/AUTO_SETUP_BOOT_WAIT_FOR_NETWORK=0/
s/AUTO_SETUP_HEADLESS=0/AUTO_SETUP_HEADLESS=1/
s/AUTO_SETUP_AUTOMATED=0/AUTO_SETUP_AUTOMATED=1/
s/SURVEY_OPTED_IN=-1/SURVEY_OPTED_IN=0/
s/CONFIG_NTP_MIRROR=default/CONFIG_NTP_MIRROR=debian\.pool\.ntp\.org/
EOF
  sed -i -f /tmp/patch_dietpi_txt.sed /boot/dietpi.txt
}

# ensure the USB serial is loaded
if [ -z "`grep g_serial /etc/modules`" ]; then
  echo dwc2 >> /etc/modules
  echo g_serial >> /etc/modules
  echo "dtoverlay=dwc2" >> /boot/config.txt
  edit_dietpi_txt
  reboot
fi

# ensure the USB serial console is enabled
if [ ! -e /boot/.gs0enabled ]; then
  systemctl enable serial-getty@ttyGS0
  touch /boot/.gs0enabled
  # intentionally poweroff, notify the user that the next boot would bring the console up
  poweroff
fi
