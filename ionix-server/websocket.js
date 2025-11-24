// // // websocket.js
// // const WebSocket = require("ws");
// // const deviceService = require("./services/device.service");

// // module.exports = (server, log = console.log) => {
// //     const wss = new WebSocket.Server({ server, path: "/ws" });

// //     log("📡 WebSocket server started at /ws");

// //     wss.on("connection", (ws, req) => {
// //         const clientIP = req.socket.remoteAddress;
// //         log(`🔥 Device connected via WebSocket (IP: ${clientIP})`);

// //         // Save this socket as THE connected IoT device (for now)
// //         deviceService.setDeviceSocket(ws);

// //         // TODO: Future — authenticate device using DEVICE_ID + DEVICE_KEY
// //         // Example: expect
// //         // { type: "auth", deviceId: "...", key: "..." }

// //         ws.on("message", (msg) => {
// //             log(`📩 Message from device (${clientIP}): ${msg.toString()}`);

// //             // TODO: Parse JSON packets, handle status, heartbeat, etc.
// //         });

// //         ws.on("close", () => {
// //             log(`❌ Device disconnected (IP: ${clientIP})`);
// //             deviceService.clearDeviceSocket();
// //         });

// //         ws.on("error", (err) => {
// //             log(`⚠ WebSocket error (${clientIP}):`, err);
// //         });
// //     });
// // };

// // websocket.js
// // websocket.js
// const WebSocket = require("ws");
// const Device = require("./models/device.model");

// module.exports = (server, log = console.log) => {
//     const wss = new WebSocket.Server({ server, path: "/ws" });

//     // deviceId → WebSocket connection
//     const liveSockets = new Map();

//     log("📡 WebSocket server started at /ws");

//     wss.on("connection", (ws, req) => {
//         const clientIP = req.socket.remoteAddress;
//         log(`🔥 Device connected via WebSocket (IP: ${clientIP})`);

//         let connectedDeviceId = null;

//         ws.on("message", async (raw) => {
//             let data;
//             try {
//                 data = JSON.parse(raw.toString());
//             } catch (e) {
//                 return log("❌ Invalid JSON from device");
//             }

//             console.log("📩 Message from device", data);

//             // 1️⃣ HELLO (device identification)
//             if (data.type === "HELLO" || data.unique_id) {
//                 const deviceId = data.deviceId || data.unique_id;

//                 connectedDeviceId = deviceId;
//                 liveSockets.set(deviceId, ws);

//                 // Update or register device
//                 let device = await Device.findOne({ deviceId });
//                 if (!device) {
//                     await Device.create({
//                         deviceId,
//                         name: data.project || deviceId,
//                         status: "online",
//                         ip: clientIP,
//                         lastSeen: new Date(),
//                     });
//                     log(`🆕 New device registered → ${deviceId}`);
//                 } else {
//                     await Device.updateOne(
//                         { deviceId },
//                         { status: "online", ip: clientIP, lastSeen: new Date() }
//                     );
//                     log(`♻ Device reconnected → ${deviceId}`);
//                 }

//                 ws.send(JSON.stringify({ type: "HELLO_ACK", deviceId }));
//                 return;
//             }

//             // Block everything else until HELLO received
//             if (!connectedDeviceId) {
//                 return ws.send(JSON.stringify({ type: "ERROR", message: "Send HELLO first" }));
//             }

//             // 2️⃣ HEARTBEAT
//             if (data.type === "HEARTBEAT") {
//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     { lastSeen: new Date(), status: "online" }
//                 );
//                 log(`❤️ HEARTBEAT from ${connectedDeviceId}`);
//                 return;
//             }

//             // 3️⃣ SYSTEM_STATUS (uptime, wifi strength, relay status)
//             if (data.type === "SYSTEM_STATUS") {
//                 log(`🟢 SYSTEM_STATUS from ${connectedDeviceId}`);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     {
//                         lastSeen: new Date(),
//                         status: "online",
//                         uptime: data.uptime_s,
//                         wifi_rssi: data.wifi_rssi,
//                         lastCommand: data.last_command,
//                         relays: data.relays,
//                     }
//                 );

//                 return;
//             }

//             // 4️⃣ SNAPSHOT (relay list only)
//             if (data.type === "SNAPSHOT") {
//                 log(`📦 SNAPSHOT received from ${connectedDeviceId}`);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     { relays: data.relays, lastSeen: new Date() }
//                 );
//                 return;
//             }

//             // 5️⃣ Device LOG message
//             if (data.type === "LOG") {
//                 log(`📝 LOG from ${connectedDeviceId}: ${data.message}`);
//                 return;
//             }

//             // Default: unknown type
//             log(`📨 Unknown message type from ${connectedDeviceId}`, data);
//         });

//         // 🔌 Device Disconnect
//         ws.on("close", async () => {
//             if (connectedDeviceId) {
//                 liveSockets.delete(connectedDeviceId);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     { status: "offline", lastSeen: new Date() }
//                 );

//                 log(`❌ Device disconnected → ${connectedDeviceId}`);
//             }
//         });

//         ws.on("error", (err) => {
//             log(`⚠ WebSocket error:`, err);
//         });
//     });

//     // 🟩 Functions exposed to backend APIs
//     return {
//         // Send any JSON message to device
//         sendToDevice(deviceId, data) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;
//             socket.send(JSON.stringify(data));
//             return true;
//         },

//         // Request device for real-time status
//         requestStatus(deviceId) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({ command: "GET_STATUS" }));
//             return true;
//         }
//     };
// };


// // websocket.js
// const WebSocket = require("ws");
// const Device = require("./models/device.model");

// module.exports = (server, log = console.log) => {
//     const wss = new WebSocket.Server({ server, path: "/ws" });

//     // deviceId → WebSocket
//     const liveSockets = new Map();

//     log("📡 WebSocket server started at /ws");

//     wss.on("connection", (ws, req) => {
//         const clientIP = req.socket.remoteAddress;
//         log(`🔥 Device connected (IP: ${clientIP})`);

//         let connectedDeviceId = null;

//         ws.on("message", async (raw) => {
//             let data;
//             try {
//                 data = JSON.parse(raw.toString());
//             } catch {
//                 return log("❌ Invalid JSON from device");
//             }

//             console.log("📩 Message from device:", data);

//             // -------------------------------------------------------
//             // 1️⃣ HELLO
//             // -------------------------------------------------------
//             if (data.type === "HELLO" || data.unique_id) {
//                 const deviceId = data.deviceId || data.unique_id;
//                 connectedDeviceId = deviceId;

//                 liveSockets.set(deviceId, ws);

//                 let device = await Device.findOne({ deviceId });

//                 if (!device) {
//                     await Device.create({
//                         deviceId,
//                         name: data.project || deviceId,
//                         status: "online",
//                         ip: clientIP,
//                         lastSeen: new Date(),
//                     });
//                     log(`🆕 Device registered → ${deviceId}`);
//                 } else {
//                     await Device.updateOne(
//                         { deviceId },
//                         { status: "online", ip: clientIP, lastSeen: new Date() }
//                     );
//                     log(`♻ Device reconnected → ${deviceId}`);
//                 }

//                 ws.send(JSON.stringify({ type: "HELLO_ACK", deviceId }));
//                 return;
//             }

//             // Block other commands until HELLO
//             if (!connectedDeviceId) {
//                 return ws.send(JSON.stringify({ type: "ERROR", message: "Send HELLO first" }));
//             }

//             // -------------------------------------------------------
//             // 2️⃣ HEARTBEAT
//             // -------------------------------------------------------
//             if (data.type === "HEARTBEAT") {
//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     { lastSeen: new Date(), status: "online" }
//                 );

//                 log(`❤️ Heartbeat → ${connectedDeviceId}`);
//                 return;
//             }

//             // -------------------------------------------------------
//             // 3️⃣ DEVICE STATUS (GET_STATUS response)
//             // -------------------------------------------------------
//             if (data.type === "SYSTEM_STATUS") {
//                 log(`🟢 STATUS from ${connectedDeviceId}`);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     {
//                         lastSeen: new Date(),
//                         status: "online",
//                         relays: data.relays || [],
//                         uptime: data.uptime_s,
//                         wifi_rssi: data.wifi_rssi,
//                     }
//                 );

//                 return;
//             }

//             // -------------------------------------------------------
//             // 4️⃣ SCHEDULE UPDATE
//             // -------------------------------------------------------
//             if (data.type === "SCHEDULE_UPDATE") {
//                 log(`📅 Schedule updated from ${connectedDeviceId}`);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     {
//                         schedule: data.schedule,
//                         lastSeen: new Date()
//                     }
//                 );

//                 return;
//             }

//             // -------------------------------------------------------
//             // 5️⃣ SNAPSHOT (relay-only quick update)
//             // -------------------------------------------------------
//             if (data.type === "SNAPSHOT") {
//                 log(`📦 SNAPSHOT from ${connectedDeviceId}`);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     {
//                         relays: data.relays,
//                         lastSeen: new Date()
//                     }
//                 );
//                 return;
//             }

//             // -------------------------------------------------------
//             // 6️⃣ Device LOG
//             // -------------------------------------------------------
//             if (data.type === "LOG") {
//                 log(`📝 LOG [${connectedDeviceId}]: ${data.message}`);
//                 return;
//             }

//             // -------------------------------------------------------
//             // ❌ Unknown
//             // -------------------------------------------------------
//             log(`📨 Unknown type from ${connectedDeviceId}`, data);
//         });

//         // -------------------------------------------------------
//         // 🔌 Disconnect
//         // -------------------------------------------------------
//         ws.on("close", async () => {
//             if (connectedDeviceId) {
//                 liveSockets.delete(connectedDeviceId);

//                 await Device.updateOne(
//                     { deviceId: connectedDeviceId },
//                     { status: "offline", lastSeen: new Date() }
//                 );

//                 log(`❌ Device disconnected → ${connectedDeviceId}`);
//             }
//         });

//         ws.on("error", (err) => log("⚠ WebSocket error:", err));
//     });

//     // -------------------------------------------------------
//     // 🌐 BACKEND COMMANDS to Device
//     // -------------------------------------------------------
//     return {
//         // Send ANY command
//         sendToDevice(deviceId, data) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify(data));
//             return true;
//         },

//         // GET_STATUS
//         requestStatus(deviceId) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({ command: "GET_STATUS" }));
//             return true;
//         },

//         // RELAY ON
//         relayOn(deviceId, relayId) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({
//                 command: "ON",
//                 relay_id: relayId,
//             }));

//             log(`⚡ ON → ${deviceId} (Relay ${relayId})`);
//             return true;
//         },

//         // RELAY OFF
//         relayOff(deviceId, relayId) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({
//                 command: "OFF",
//                 relay_id: relayId,
//             }));

//             log(`🛑 OFF → ${deviceId} (Relay ${relayId})`);
//             return true;
//         },

//         // RELAY TOGGLE
//         toggleRelay(deviceId, relayId) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({
//                 command: "TOGGLE",
//                 relay_id: relayId,
//             }));

//             log(`🔄 TOGGLE → ${deviceId} (Relay ${relayId})`);
//             return true;
//         },

//         // SET TIMER
//         setTimer(deviceId, relayId, seconds) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({
//                 command: "SET_TIMER",
//                 relay_id: relayId,
//                 value: seconds,
//             }));

//             log(`⏳ TIMER → ${deviceId} (Relay ${relayId}, ${seconds}s)`);
//             return true;
//         },

//         // SET SCHEDULE
//         setSchedule(deviceId, relayId, scheduleData) {
//             const socket = liveSockets.get(deviceId);
//             if (!socket) return false;

//             socket.send(JSON.stringify({
//                 command: "SET_SCHEDULE",
//                 relay_id: relayId,
//                 schedule_data: scheduleData,
//             }));

//             log(`📅 SCHEDULE → ${deviceId} (Relay ${relayId})`);
//             return true;
//         }
//     };
// };




const WebSocket = require("ws");
const Device = require("./models/device.model");

module.exports = (server, log = console.log) => {
    const wss = new WebSocket.Server({ server, path: "/ws" });

    // ESP devices (hardware) → deviceId → WebSocket
    const deviceSockets = new Map();

    // Mobile clients → random id → WebSocket
    const mobileSockets = new Map();

    log("📡 WebSocket server started at /ws");

    wss.on("connection", (ws, req) => {
        const clientIP = req.socket.remoteAddress;
        log(`🔥 Client Connected (IP: ${clientIP})`);

        let connectedDeviceId = null;
        const clientId = Date.now().toString();
        mobileSockets.set(clientId, ws); // added by default

        ws.on("message", async (raw) => {
            let data;
            try {
                data = JSON.parse(raw.toString());
            } catch {
                return log("❌ Invalid JSON from device");
            }

            console.log("📩 Incoming Message:", data);

            // -------------------------------------------------------------------
            // 👉 MOBILE APP EVENTS
            // -------------------------------------------------------------------
            if (data.from === "mobile") {
                return handleMobileMessage(ws, data);
            }

            // -------------------------------------------------------------------
            // 👉 ESP DEVICE (Hardware) EVENTS
            // -------------------------------------------------------------------
            handleDeviceMessage(ws, data);
        });

        // -------------------------------------------------------------------
        // 🔌 Disconnect
        // -------------------------------------------------------------------
        ws.on("close", async () => {
            mobileSockets.delete(clientId);

            if (connectedDeviceId) {
                deviceSockets.delete(connectedDeviceId);

                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { status: "offline", lastSeen: new Date() }
                );

                log(`❌ ESP Device disconnected → ${connectedDeviceId}`);
            }
        });

        ws.on("error", (err) => log("⚠ WebSocket error:", err));

        // -------------------------------------------------------------------
        // HANDLER: ESP DEVICE MESSAGES
        // -------------------------------------------------------------------
        async function handleDeviceMessage(ws, data) {

            // 1️⃣ HELLO from ESP
            if (data.type === "HELLO" || data.unique_id) {
                const deviceId = data.deviceId || data.unique_id;
                connectedDeviceId = deviceId;

                deviceSockets.set(deviceId, ws);

                let device = await Device.findOne({ deviceId });

                if (!device) {
                    await Device.create({
                        deviceId,
                        name: data.project || deviceId,
                        status: "online",
                        ip: clientIP,
                        lastSeen: new Date(),
                    });
                    log(`🆕 Device registered → ${deviceId}`);
                } else {
                    await Device.updateOne(
                        { deviceId },
                        { status: "online", ip: clientIP, lastSeen: new Date() }
                    );
                    log(`♻ Device reconnected → ${deviceId}`);
                }

                ws.send(JSON.stringify({ type: "HELLO_ACK", deviceId }));
                broadcastToMobiles({
                    event: "deviceOnline",
                    deviceId
                });
                return;
            }

            if (!connectedDeviceId) {
                return ws.send(JSON.stringify({ type: "ERROR", message: "Send HELLO first" }));
            }

            // 2️⃣ HEARTBEAT
            if (data.type === "HEARTBEAT") {
                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    { lastSeen: new Date(), status: "online" }
                );
                return;
            }

            // 3️⃣ STATUS UPDATE
            if (data.type === "SYSTEM_STATUS") {
                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    {
                        lastSeen: new Date(),
                        status: "online",
                        relays: data.relays || [],
                        uptime: data.uptime_s,
                        wifi_rssi: data.wifi_rssi,
                    }
                );

                const updated = await Device.findOne({ deviceId: connectedDeviceId });
                broadcastToMobiles({
                    event: "deviceUpdated",
                    device: updated
                });
                return;
            }

            // 4️⃣ SNAPSHOT (only relays)
            if (data.type === "SNAPSHOT") {
                await Device.updateOne(
                    { deviceId: connectedDeviceId },
                    {
                        relays: data.relays,
                        lastSeen: new Date(),
                    }
                );

                const updated = await Device.findOne({ deviceId: connectedDeviceId });
                broadcastToMobiles({
                    event: "deviceUpdated",
                    device: updated
                });
                return;
            }

            // 5️⃣ LOG
            if (data.type === "LOG") {
                log(`📝 LOG [${connectedDeviceId}]: ${data.message}`);
                return;
            }

            log("❓ Unknown ESP payload", data);
        }

        // -------------------------------------------------------------------
        // HANDLER: MOBILE APP MESSAGES
        // -------------------------------------------------------------------
        async function handleMobileMessage(ws, data) {
            // 1️⃣ FETCH ALL DEVICES
            if (data.event === "getDevices") {
                const devices = await Device.find({});
                ws.send(JSON.stringify({
                    event: "devicesList",
                    devices,
                }));
                return;
            }

            // 2️⃣ TOGGLE RELAY
            if (data.event === "toggleRelay") {
                const { deviceId, relayId } = data;

                const socket = deviceSockets.get(deviceId);
                if (!socket) {
                    return ws.send(JSON.stringify({
                        event: "error",
                        message: "Device offline"
                    }));
                }

                socket.send(JSON.stringify({
                    command: "TOGGLE",
                    relay_id: relayId,
                }));

                return;
            }

            // 3️⃣ REQUEST STATUS
            if (data.event === "getStatus") {
                const socket = deviceSockets.get(data.deviceId);
                if (socket) {
                    socket.send(JSON.stringify({ command: "GET_STATUS" }));
                }
                return;
            }
        }
    });

    // -------------------------------------------------------------------
    // BROADCAST TO ALL MOBILE APPS
    // -------------------------------------------------------------------
    function broadcastToMobiles(payload) {
        const str = JSON.stringify(payload);
        mobileSockets.forEach((ws) => {
            if (ws.readyState === WebSocket.OPEN) ws.send(str);
        });
    }

    // -------------------------------------------------------------------
    // EXPOSE COMMAND FUNCTIONS
    // -------------------------------------------------------------------
    return {
        sendToDevice(deviceId, payload) {
            const socket = deviceSockets.get(deviceId);
            if (!socket) return false;
            socket.send(JSON.stringify(payload));
            return true;
        },
        toggleRelay(deviceId, relayId) {
            return this.sendToDevice(deviceId, {
                command: "TOGGLE",
                relay_id: relayId,
            });
        },
        requestStatus(deviceId) {
            return this.sendToDevice(deviceId, { command: "GET_STATUS" });
        }
    };
};
