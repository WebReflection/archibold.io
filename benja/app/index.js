// to have access to local or global scripts
require(process.cwd() + '/node_modules/benja').paths();

// basic static server
const compression = require('compression');
const express = require('express');
const server = express();
server
  // comment out next line to stress the CPU less
  .use(compression())
  .use(express.static('.'))
  .listen(8080);

// electron app
const electron = require('electron');
const {BrowserWindow, app} = electron;
app.commandLine.appendSwitch('--ignore-gpu-blacklist');

app.once('ready', () => {

  const {width, height} = electron.screen.getPrimaryDisplay().workAreaSize;
  let window = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true,
      nodeIntegrationInWorker: true,
      webgl: true
    },
    backgroundColor: '#000000',
    frame: false,
    // in some case kiosk: true is not working
    // same goes for fullscreen but this is working
    fullscreen: true,
    x: 0,
    y: 0,
    width,
    height
  });

  window
    .once('closed', () => { window = null; })
    .loadURL('http://localhost:8080/');
    // test CSS
 // .loadURL('https://bennettfeely.com/csscreatures/');
    // test WebGL
 // .loadURL('http://get.webgl.org/');
    // stress WebGL
 // .loadURL('https://threejs.org/examples/webgl_geometry_cube.html');


  // for debugging purpose, it might be handy to be able
  // to reload the app simply via `touch ~/app/reload`
  require('fs').watch('reload', () => app.quit());
});
