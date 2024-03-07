#!/bin/bash

# ensure the USB serial is loaded
if [ -n `grep "modules-load" /boot/cmdline.txt` ]; then
  sed -i "s/rootwait/rootwait modules-load=dwc2,g_serial/" /boot/cmdline.txt
  echo "dtoverlay=dwc2" >> /boot/config.txt
  sed -i -f /boot/patch_dietpi_txt.sed /boot/dietpi.txt
  reboot
fi

# ensure the USB serial console is enabled
if [ ! -e /boot/.gs0enabled ]; then
  systemctl enable serial-getty@ttyGS0
  touch /boot/.gs0enabled
  # intentionally poweroff, notify the user that the next boot would bring the console up
  poweroff
fi