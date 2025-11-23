// server.js
require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// Routes
const deviceRoutes = require("./controllers/device.controller");
app.use("/device", deviceRoutes);

// Start Express Server
const server = app.listen(PORT, () => {
    console.log(`REST API running on http://localhost:${PORT}`);
});

// Start WebSocket server
require("./websocket")(server);
