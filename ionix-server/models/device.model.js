// models/device.model.js
const mongoose = require("mongoose");

const RelaySchema = new mongoose.Schema({
  relay_id: { type: Number, required: true },
  name: { type: String },
  state: { type: Boolean, default: false },
  countdown_s: { type: Number, default: 0 },
  schedule: { type: mongoose.Schema.Types.Mixed, default: {} }
}, { _id: false });

const DeviceSchema = new mongoose.Schema({
  deviceId: { type: String, required: true, unique: true, index: true }, // e.g. "b3projects-relays"
  keyHash: { type: String }, // hashed DEVICE_KEY (store hashed for security)
  name: { type: String, default: "Unnamed Device" },
  status: { type: String, enum: ["online","offline","unknown"], default: "unknown" },
  lastSeen: { type: Date, default: null },
  ip: { type: String, default: null },
  relays: { type: [RelaySchema], default: [] }, // snapshot of current relays
  meta: { type: mongoose.Schema.Types.Mixed, default: {} }, // any extra metadata
}, { timestamps: true });

module.exports = mongoose.model("Device", DeviceSchema);
