# An Hardware Accelerated Raspberry Pi Kiosk

This installer bootstraps [WPE WebKit](https://wpewebkit.org/) via Node.js, Weston, and [cog](https://github.com/Igalia/cog#readme).



### How to install?

Follow ArchLinuxARM instructions for [Pi 2](https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2), [Pi 3](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3), or [Pi 4](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4).

At the very first boot from the SD card, login via `alarm` user and `alarm` password, be sure your Pi is connected to the internet, either via network cable, or WiFi (`su -c wifi-menu`), and then type the following:

```sh
bash <(curl -s https://archibold.io/kiosk/pi/wpe)
```

Follow the instructions, wait 10 to 20 minutes for the raspberry to reboot, enjoy the HW accelerated [jellyfish](https://archibold.io/demo/jellyfish/) demo.



### How can I customize it?

The Node.js file will be located in `~/www/index.js` and you can change it as you like, or even drop it, if you don't need Node.js.

In such case, you can point `~/.config/weston.ini` to point at different executable on boot.



### Is this like Electron / B.E.N.J.A.?

It's not, the browser is WPE built with all options on, but you need [Electroff](https://medium.com/@WebReflection/electroff-an-electron-less-alternative-10920c6003b8) to have a similar experience you would have with Electron.
