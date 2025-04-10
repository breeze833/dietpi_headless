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
Most of them are the procedures for a console (GUI or non-GUI) with a display and keyboard/mouse.
My configuration requires no input/output devices throughout the installation process.
That is, the user can access the system only after the serial console is ready.

[DiepPi](https://dietpi.com/) is a lightweight distribution for various platforms.
It allows the scripts for customizing the installaion procedure.
By this mechanism, we can achieve the true headless installation.

## How to Do

Here are the steps for preparing the microSD card:
  1. download the OS image from the DietPi website
  1. put the image on the microSD card
  1. use a card reader to access the boot partition
  1. copy the files in the `boot/` directory to the boot partition
  1. copy the `dietpi-wifi.txt.sample` to `dietpi-wifi.txt`
  1. customize `dietpi-wifi.txt` as needed (you need at least one working WiFi access entry)
     1. the example of index 0 is specific to the TKU campus
     1. the example of index 1 is for general WiFi WPA2 access
  1. plug the USB cable to the USB port (**NOT** the PWR port) of the board
  1. plug the USB cable to the host computer
  1. re-plug the USB cable when the power LED is turned off (the 1st time)
  1. re-plug the USB cable when the power LED is turned off (the 2nd time)
  1. use a terminal emulator to access the serial console
     - for example, PuTTY
     - example device: /dev/ttyACM0 on Linux
     - example device: COM3 on Windows
  1. the default username/password is dietpi/dietpi 

## Verified Versions

  - DietPi 9.11.2
  - DietPi 9.10.0
  - DietPi 9.9.0
