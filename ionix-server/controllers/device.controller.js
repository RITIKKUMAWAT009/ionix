// controllers/device.controller.js
const express = require("express");
const router = express.Router();
const deviceService = require("../services/device.service");
const Device = require("../models/device.model");

// GET: Check if device is online (tries deviceService then DB)
router.get("/status", async (req, res) => {
  try {
    const online = deviceService.isDeviceConnected();
    // Also fetch DB record for more info (if available)
    const deviceDoc = await Device.findOne().sort({ updatedAt: -1 }).lean().exec();
    const dbInfo = deviceDoc ? {
      deviceId: deviceDoc.deviceId,
      status: deviceDoc.status,
      lastSeen: deviceDoc.lastSeen,
      ip: deviceDoc.ip
    } : null;

    res.json({ online, dbInfo });
  } catch (err) {
    console.error("status error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

// Relay control endpoints remain the same, but we also update DB when a command is sent
router.post("/relay/on", async (req, res) => {
  try {
    deviceService.sendCommand({ command: "relay_on" });

    // Update DB (mark lastCommand)
    const d = await Device.findOne().sort({ updatedAt: -1 });
    if (d) {
      d.meta = d.meta || {};
      d.meta.lastCommand = "relay_on";
      await d.save();
    }

    res.json({ success: true, message: "Relay ON command sent" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post("/relay/off", async (req, res) => {
  try {
    deviceService.sendCommand({ command: "relay_off" });
    const d = await Device.findOne().sort({ updatedAt: -1 });
    if (d) {
      d.meta = d.meta || {};
      d.meta.lastCommand = "relay_off";
      await d.save();
    }
    res.json({ success: true, message: "Relay OFF command sent" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
