#!/usr/bin/env node

const {exec} = require("child_process");
const {join} = require("path");

const compression = require("compression");
const express = require("express");

express()
  .use(compression())
  .use(express.static(join(__dirname, "jellyfish")))
  .get("/quit", () => process.exit(0))
  .get("/ips", (_, res) => {
    const ips = new Set;
    for (const [_, nets] of Object.entries(require("os").networkInterfaces())) {
      for (const net of nets) {
        if (net.family === "IPv4" && !net.internal)
          ips.add(net.address);
      }
    }
    res.writeHead(200, {
      "content-type": "application/json"
    });
    res.end(JSON.stringify([...ips]));
  })
  .listen(8080, () => {
    exec("cog http://127.0.0.1:8080/index.html");
  });
