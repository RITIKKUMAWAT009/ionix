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
// websocket.js
const WebSocket = require("ws");
const Device = require("./models/device.model");

module.exports = (server, log = console.log) => {
    const wss = new WebSocket.Server({ server, path: "/ws" });

    // deviceId → WebSocket connection
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

            console.log("📩 Message from device", data);

            // 1️⃣ HELLO (device identification)
            if (data.type === "HELLO" || data.unique_id) {
                const deviceId = data.deviceId || data.unique_id;

                connectedDeviceId = deviceId;
                liveSockets.set(deviceId, ws);

                // Update or register device
                let device = await Device.findOne({ deviceId });
                if (!device) {
                    await Device.create({
                        deviceId,
                        name: data.project || deviceId,
                        status: "online",
                        ip: clientIP,
                        lastSeen: new Date(),
                    });
                    log(`🆕 New device registered → ${deviceId}`);
                } else {
                    await Device.updateOne(
                        { deviceId },
                        { status: "online", ip: clientIP, lastSeen: new Date() }
                    );
                    log(`♻ Device reconnected → ${deviceId}`);
                }

                ws.send(JSON.stringify({ type: "HELLO_ACK", deviceId }));
                return;
            }

            // Block everything else until HELLO received
            if (!connectedDeviceId) {
                return ws.send(JSON.stringify({ type: "ERROR", message: "Send HELLO first" }));
            }

            // 2️⃣ HEARTBEAT
            if (data.type === "HEARTBEAT") {
                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { lastSeen: new Date(), status: "online" }
                );
                log(`❤️ HEARTBEAT from ${connectedDeviceId}`);
                return;
            }

            // 3️⃣ SYSTEM_STATUS (uptime, wifi strength, relay status)
            if (data.type === "SYSTEM_STATUS") {
                log(`🟢 SYSTEM_STATUS from ${connectedDeviceId}`);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    {
                        lastSeen: new Date(),
                        status: "online",
                        uptime: data.uptime_s,
                        wifi_rssi: data.wifi_rssi,
                        lastCommand: data.last_command,
                        relays: data.relays,
                    }
                );

                return;
            }

            // 4️⃣ SNAPSHOT (relay list only)
            if (data.type === "SNAPSHOT") {
                log(`📦 SNAPSHOT received from ${connectedDeviceId}`);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { relays: data.relays, lastSeen: new Date() }
                );
                return;
            }

            // 5️⃣ Device LOG message
            if (data.type === "LOG") {
                log(`📝 LOG from ${connectedDeviceId}: ${data.message}`);
                return;
            }

            // Default: unknown type
            log(`📨 Unknown message type from ${connectedDeviceId}`, data);
        });

        // 🔌 Device Disconnect
        ws.on("close", async () => {
            if (connectedDeviceId) {
                liveSockets.delete(connectedDeviceId);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { status: "offline", lastSeen: new Date() }
                );

                log(`❌ Device disconnected → ${connectedDeviceId}`);
            }
        });

        ws.on("error", (err) => {
            log(`⚠ WebSocket error:`, err);
        });
    });

    // 🟩 Functions exposed to backend APIs
    return {
        // Send any JSON message to device
        sendToDevice(deviceId, data) {
            const socket = liveSockets.get(deviceId);
            if (!socket) return false;
            socket.send(JSON.stringify(data));
            return true;
        },

        // Request device for real-time status
        requestStatus(deviceId) {
            const socket = liveSockets.get(deviceId);
            if (!socket) return false;

            socket.send(JSON.stringify({ command: "GET_STATUS" }));
            return true;
        }
    };
};
