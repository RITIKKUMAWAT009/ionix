// controllers/device.controller.js
const express = require("express");
const router = express.Router();

const deviceService = require("../services/device.service");

// -----------------------------------
// GET: Check if device is online
// -----------------------------------
router.get("/status", (req, res) => {
    res.json({
        online: deviceService.isDeviceConnected()
    });
});

// -----------------------------------
// POST: Turn a relay ON
// -----------------------------------
router.post("/relay/on", (req, res) => {
    try {
        deviceService.sendCommand({ command: "relay_on" });
        res.json({ success: true, message: "Relay ON command sent" });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// -----------------------------------
// POST: Turn a relay OFF
// -----------------------------------
router.post("/relay/off", (req, res) => {
    try {
        deviceService.sendCommand({ command: "relay_off" });
        res.json({ success: true, message: "Relay OFF command sent" });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// -----------------------------------
// TODO: Add authentication here later
// - Verify API tokens
// - Validate device register packet
// - Store deviceId in DB
// -----------------------------------

module.exports = router;
