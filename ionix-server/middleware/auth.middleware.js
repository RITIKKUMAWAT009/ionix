// middleware/auth.middleware.js
const jwt = require("jsonwebtoken");
const Device = require("../models/device.model");

const JWT_SECRET = process.env.JWT_SECRET;

async function deviceAuth(req, res, next) {
  // Expect header: Authorization: Bearer <token>
  const header = req.headers.authorization || "";
  const token = header.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Missing token" });

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    // payload.deviceId exists (as we signed it)
    const device = await Device.findOne({ deviceId: payload.deviceId });
    if (!device) return res.status(401).json({ message: "Invalid device" });

    // Attach device to request for handlers
    req.device = device;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

module.exports = { deviceAuth };
