// // websocket.js
// const WebSocket = require("ws");
// const deviceService = require("./services/device.service");

// module.exports = (server, log = console.log) => {
//     const wss = new WebSocket.Server({ server, path: "/ws" });

//     log("📡 WebSocket server started at /ws");

//     wss.on("connection", (ws, req) => {
//         const clientIP = req.socket.remoteAddress;
//         log(`🔥 Device connected via WebSocket (IP: ${clientIP})`);

//         // Save this socket as THE connected IoT device (for now)
//         deviceService.setDeviceSocket(ws);

//         // TODO: Future — authenticate device using DEVICE_ID + DEVICE_KEY
//         // Example: expect
//         // { type: "auth", deviceId: "...", key: "..." }

//         ws.on("message", (msg) => {
//             log(`📩 Message from device (${clientIP}): ${msg.toString()}`);

//             // TODO: Parse JSON packets, handle status, heartbeat, etc.
//         });

//         ws.on("close", () => {
//             log(`❌ Device disconnected (IP: ${clientIP})`);
//             deviceService.clearDeviceSocket();
//         });

//         ws.on("error", (err) => {
//             log(`⚠ WebSocket error (${clientIP}):`, err);
//         });
//     });
// };

// websocket.js
const WebSocket = require("ws");
const Device = require("./models/device.model");

module.exports = (server, log = console.log) => {
    const wss = new WebSocket.Server({ server, path: "/ws" });

    // deviceId → WebSocket
    const liveSockets = new Map();

    log("📡 WebSocket server started at /ws");

    wss.on("connection", (ws, req) => {
        const clientIP = req.socket.remoteAddress;
        log(`🔥 Device connected via WebSocket (IP: ${clientIP})`);

        let connectedDeviceId = null;

        ws.on("message", async (raw) => {
            let data;
            try {
                data = JSON.parse(raw.toString());
            } catch (e) {
                return log("❌ Invalid JSON from device");
            }

            // -------------------------
            // 1️⃣ DEVICE IDENTIFICATION (NO AUTH)
            // Device must first send:
            // { type: "HELLO", deviceId: "b3projects-relays" }
            // -------------------------
            if (data.type === "HELLO") {
                const { deviceId } = data;

                connectedDeviceId = deviceId;
                liveSockets.set(deviceId, ws);

                // Create device if not exists
                let device = await Device.findOne({ deviceId });
                if (!device) {
                    device = new Device({
                        deviceId,
                        name: deviceId,
                        status: "online",
                        ip: clientIP,
                        lastSeen: new Date(),
                    });
                    await device.save();
                    log(`🆕 New device registered → ${deviceId}`);
                } else {
                    // Mark device online
                    device.status = "online";
                    device.ip = clientIP;
                    device.lastSeen = new Date();
                    await device.save();
                    log(`♻ Device reconnected → ${deviceId}`);
                }

                ws.send(JSON.stringify({ type: "HELLO_ACK", deviceId }));
                return;
            }

            // Block all other messages until HELLO received
            if (!connectedDeviceId) {
                return ws.send(JSON.stringify({ type: "ERROR", message: "Send HELLO first" }));
            }

            // -------------------------
            // 2️⃣ HEARTBEAT
            // -------------------------
            if (data.type === "HEARTBEAT") {
                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { lastSeen: new Date(), status: "online" }
                );
                log(`❤️ HEARTBEAT from ${connectedDeviceId}`);
                return;
            }

            // -------------------------
            // 3️⃣ RELAY SNAPSHOT UPDATE
            // Device sends:
            // { type: "SNAPSHOT", relays: [...] }
            // -------------------------
            if (data.type === "SNAPSHOT") {
                log(`📦 SNAPSHOT received from ${connectedDeviceId}`);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    {
                        relays: data.relays,
                        lastSeen: new Date(),
                    }
                );

                return;
            }

            // -------------------------
            // 4️⃣ REUSABLE FUTURE TYPE HANDLER
            // -------------------------
            log(`📩 Message from ${connectedDeviceId}:`, data);
        });

        // ---------------------------------------
        // HANDLE DISCONNECT
        // ---------------------------------------
        ws.on("close", async () => {
            if (connectedDeviceId) {
                liveSockets.delete(connectedDeviceId);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { status: "offline" }
                );

                log(`❌ Device disconnected → ${connectedDeviceId}`);
            }
        });

        ws.on("error", (err) => {
            log(`⚠ WebSocket error:`, err);
        });
    });

    // Allow backend to send to device
    return {
        sendToDevice(deviceId, data) {
            const socket = liveSockets.get(deviceId);
            if (!socket) return false;
            socket.send(JSON.stringify(data));
            return true;
        },
    };
};
