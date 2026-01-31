# Headless Setup for DietPi

## Goal

To install the OS to a Raspberry Pi Zero 2 W in a *true* headless way.

## Usage Scenario

I teach a course in which the students use Raspberry Pi Zero 2 W for practicing Linux and project development.
The configuration is
  - headless (no display and keyboard attached to the board)
  - minimum installation of the OS
  - allow accessing the serial console via the USB port
  
## Description

There are various installation tutorials on the Internet.
Most of them are the procedures for a physical console (GUI or non-GUI) with a display and keyboard/mouse.
My approach is to set up a serial console over the USB cable. Afterwards, the user can access the console from the host computer, login and follow the installation screens, and finally finish the procedure.

[DiepPi](https://dietpi.com/) is a lightweight distribution for various platforms.
It allows the scripts for customizing the installaion procedure.
By this mechanism, we can achieve the true headless installation.

## How to Do

Here are the steps for preparing the microSD card:
  1. download the OS image from the DietPi website
  1. put the image on the microSD card
  1. use a card reader to access the boot partition
  1. copy the files in the `boot/` directory to the boot partition
  1. plug the USB cable to the USB port (**NOT** the PWR port) of the board
  1. plug the USB cable to the host computer
  1. re-plug the USB cable when the power LED is turned off (the 1st time)
  1. use a terminal emulator to access the serial console
     - for example, PuTTY
     - example device: `/dev/ttyACM0` on Linux
     - example device: `COM3` on Windows
     - There are a few bootstrap tasks to complete. It may take a few minutes to reach the login prompt.
  1. the default username/password is `root`/`dietpi`
     - configure the Internet access
     - finish the base installation
  1. re-plug the USB cable when the power LED is turned off (the 2nd time)
     - boot into the normal mode
     - suggested login username is `dietpi`; the password is the one specified during the installation process

## Features

The USB gadget would appear as a composite device including the following functions:
  1. serial device (configured as a login console)
  1. network device (configured with link-local address, default `169.254.1.1`)
  1. mass-storage device (optional, you may create `/var/lib/usb\_storage.bin` as the storage space)

## Verified Versions

  - DietPi 10.0.1
