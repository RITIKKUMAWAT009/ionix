// websocket.js
const WebSocket = require("ws");
const deviceService = require("./services/device.service");

module.exports = (server) => {
    const wss = new WebSocket.Server({ server, path: "/ws" });

    wss.on("connection", (ws) => {
        console.log("🔥 Device connected via WebSocket");

        // Save socket as the ONE and only device for now
        deviceService.setDeviceSocket(ws);

        // TODO: In future — validate device with register packet
        // e.g., expect first message: { type: 'register', deviceId, key }

        ws.on("message", (msg) => {
            console.log("📩 Message from device:", msg.toString());

            // TODO: Future — parse JSON, handle actions like status update, heartbeat, etc.
        });

        ws.on("close", () => {
            console.log("❌ Device disconnected");
            deviceService.clearDeviceSocket();
        });

        ws.on("error", (err) => {
            console.log("⚠ WebSocket error:", err);
        });
    });

    console.log("WebSocket server started at /ws");
};
