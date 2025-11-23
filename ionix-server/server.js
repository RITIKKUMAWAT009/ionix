// server.js
require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();

// -------------------------------
// CONFIG
// -------------------------------
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";
const EC2_IP = process.env.EC2_IP || "localhost";

const BASE_URL = `http://${EC2_IP}:${PORT}`;
const WS_URL = `ws://${EC2_IP}:${PORT}/ws`;

// -------------------------------
// LOGGER
// -------------------------------
const log = (...args) => {
  console.log(`[${new Date().toISOString()}]`, ...args);
};

// -------------------------------
// MIDDLEWARE
// -------------------------------
app.use(express.json());
app.use(cors());

// -------------------------------
// ROUTES
// -------------------------------
const deviceRoutes = require("./controllers/device.controller");
app.use("/device", deviceRoutes);

// -------------------------------
// START EXPRESS SERVER
// -------------------------------
const server = app.listen(PORT, HOST, () => {
  log(`🚀 REST API running at: ${BASE_URL}`);
  log(`🔌 WebSocket running at: ${WS_URL}`);
});

// -------------------------------
// START WEBSOCKET SERVER
// -------------------------------
require("./websocket")(server, log);
