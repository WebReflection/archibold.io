# B.E.N.J.A. Documentation
This page contains most basic information about BENJA and its usage.
Please note that every supported board might have slightly different setup,
hardware acceleration capabilities, or setup.



### How to create the B.E.N.J.A. environment
All you need to do, is type the following in your ArchLinux terminal, and follow the instructions:

```sh
bash <(curl -s https://archibold.io/benja/prepare)
```


### How to Develop
Creating applications is as easy as writing the following from the `APP` disk folder:
```sh
$ npm start
```
This is indeed exactly what gets executed once Benja OS starts.
If your computer works, the target board will work too!

But how about editing remotely so you don't have to keep removing and putting back the SD card?

As simple as writing:
```sh
$ ssh alarm@192.168.1.X
password: alarm
```

At this point you can use `nano ~/app/index.js` to edit that file or, if your IDE supports it, you can use [rmate](https://github.com/textmate/rmate#rmate) which is already available in Benja OS.

This gives you the ability to also test directly GPIO related operations through the board.



### How to reload the App
There are at least a couple of ways to do it: remotely and directly through the app.
The default app example uses a watcher on its main `index.js` file:

```js
// for debugging purpose, it might be handy to be able
// to reload the window simply via `touch ~/app/reload`
require('fs').watch('reload', () => app.quit());
```
Once logged in via `ssh` all you need to do is to write the following:
```sh
touch ~/app/reload
```
This will quit the app and thanks to BenjaOS configuration it will also restart it.
Alternatively you could put a simple script on the page such:
```html
<script>
// set double click handler and reload the page if triggered
document.documentElement.ondblclick = () => location.reload();
</script>
```
It could be any sort of event, or a combination of keys, a gesture, a button.
Bear in mind you could even `spawn` a `reboot` via _bash_ or shell, or even invoke a `shutdown -h now`: you have full control.



### How to load the app remotely
By default, BenjaOS redirects to port `8080` all calls to port `80`, making it simple to use from your browser the same `index.html`.
Write `http://192.168.1.X` on your browser, being sure the it is the one assigned to your board, and verify everything is OK.

However, if you plug the SD card into your laptop, you can simply run `npm start` on *BENJA-APP* folder and develop directly in there.
`Ctrl + Shift + I` to eventually bring up the console and debug like any other HTML page.



### How to not boot the App
If you'd like to play around with Arch Linux instead
of booting the app, you can either rename `~/app/package.json`
into `~/app/package.jsno` or `~/app/package.jsoff`,
or you could remove it or rename it differently, like `~/app/package.nope`.

This will inform Benja OS that it should just boot in the first available terminal, either on Weston or X11. 



### How to install App dependencies
If you remove the folder `~/app/node_modules`, Benja will install production dependencies automatically next time it starts.

This is handy if you have one project that might have dependencies that might conflict with those your computer architecture might encounter.

In general though, it is strongly suggested to use dependencies that are cross platform friendly,
and install those requiring builds and node-gyp as global module (also due the fact exacutables are not installed through a runtime mounted folder).



### How to include node modules
Due some limitation with current Electron paths, your application might need to include the [benja module](https://www.npmjs.com/package/benja) on top.
```js
// on top of index.js or index.html
// to have access to both local and global modules
require(process.cwd() + '/node_modules/benja').paths();
```
In alternative, you need to specify manually paths via:
```js
[].push.apply(
  require('module').globalPaths,
  [process.cwd() + '/node_modules']
  .concat(process.env.NODE_PATH.split(':').filter(p => 0 < p.length))
);
```



### How to Update Benja OS
Bening simply a specially configured Arch Linux OS,
all you need to update the system is the following:

```sh
# updates ArchLinux to the latest
sudo pacman -Syu

# update Electron and global modules to the latest
npm update -g
```

### Known Issues

For some reason Electron starts leaving 1 pixel width and height off.

If you have any idea how to fix that, please share, thanks.
