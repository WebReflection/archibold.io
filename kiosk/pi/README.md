# An Hardware Accelerated Kiosk

This installer bootstraps [WPE WebKit](https://wpewebkit.org/) via Node.js, Weston, and [cog](https://github.com/Igalia/cog#readme).

The Node.js file will be located in `~/www/index.js` and you can change it as you like, or even drop it, if you don't need Node.js.

In such case, you can point `~/.config/weston.ini` to point at different executable on boot.
