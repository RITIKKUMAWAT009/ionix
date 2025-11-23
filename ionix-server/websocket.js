// websocket.js
const WebSocket = require("ws");
const deviceService = require("./services/device.service");

module.exports = (server, log = console.log) => {
    const wss = new WebSocket.Server({ server, path: "/ws" });

    log("📡 WebSocket server started at /ws");

    wss.on("connection", (ws, req) => {
        const clientIP = req.socket.remoteAddress;
        log(`🔥 Device connected via WebSocket (IP: ${clientIP})`);

        // Save this socket as THE connected IoT device (for now)
        deviceService.setDeviceSocket(ws);

        // TODO: Future — authenticate device using DEVICE_ID + DEVICE_KEY
        // Example: expect
        // { type: "auth", deviceId: "...", key: "..." }

        ws.on("message", (msg) => {
            log(`📩 Message from device (${clientIP}): ${msg.toString()}`);

            // TODO: Parse JSON packets, handle status, heartbeat, etc.
        });

        ws.on("close", () => {
            log(`❌ Device disconnected (IP: ${clientIP})`);
            deviceService.clearDeviceSocket();
        });

        ws.on("error", (err) => {
            log(`⚠ WebSocket error (${clientIP}):`, err);
        });
    });
};
