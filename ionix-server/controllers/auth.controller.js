// controllers/auth.controller.js
const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const Device = require("../models/device.model");

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";
const SALT_ROUNDS = 10;

// ------------------------------------------------------------------
// POST /auth/device/register
// (Optional) create device on server side with hashed key.
// If you plan to pre-register devices on server, use this endpoint.
// ------------------------------------------------------------------
router.post("/device/register", async (req, res) => {
  try {
    const { deviceId, key, name } = req.body;
    if (!deviceId || !key) return res.status(400).json({ message: "deviceId and key required" });

    const existing = await Device.findOne({ deviceId });
    if (existing) return res.status(409).json({ message: "device already registered" });

    const keyHash = await bcrypt.hash(key, SALT_ROUNDS);
    const device = new Device({ deviceId, keyHash, name });
    await device.save();

    return res.json({ success: true, deviceId });
  } catch (err) {
    console.error("device register error:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

// ------------------------------------------------------------------
// POST /auth/device/login
// Accepts deviceId + key, validates, issues JWT, upserts device info
// (This is used by devices or server-side tools to authenticate).
// ------------------------------------------------------------------
router.post("/device/login", async (req, res) => {
  try {
    const { deviceId, key, ip, relaysSnapshot } = req.body;
    if (!deviceId || !key) return res.status(400).json({ message: "deviceId and key required" });

    // Find device
    let device = await Device.findOne({ deviceId });

    // If device isn't pre-registered, create it (auto-provisioning).
    // NOTE: You can change policy: require pre-registration instead.
    if (!device) {
      const keyHash = await bcrypt.hash(key, SALT_ROUNDS);
      device = new Device({ deviceId, keyHash, name: deviceId });
      await device.save();
    }

    // Validate key
    const match = await bcrypt.compare(key, device.keyHash);
    if (!match) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Issue JWT (for future websocket auth or admin UI)
    const token = jwt.sign({ deviceId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    // Update device status in DB (upsert snapshot)
    device.status = "online";
    device.lastSeen = new Date();
    if (ip) device.ip = ip;
    if (Array.isArray(relaysSnapshot)) device.relays = relaysSnapshot;
    await device.save();

    return res.json({ success: true, token, deviceId });
  } catch (err) {
    console.error("device login error:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

// ------------------------------------------------------------------
// GET /auth/devices
// Simple devices listing (expandable with pagination & filters)
// ------------------------------------------------------------------
router.get("/devices", async (req, res) => {
  try {
    const devices = await Device.find().sort({ updatedAt: -1 }).limit(100);
    res.json({ success: true, devices });
  } catch (err) {
    console.error("fetch devices error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = router;
