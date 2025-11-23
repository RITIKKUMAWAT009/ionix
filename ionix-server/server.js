// server.js
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const morgan = require('morgan');
const http = require('http');
const connectDB = require('./config/database');

const app = express();
const server = http.createServer(app);

// -------------------------------
// CONFIG
// -------------------------------
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";
const EC2_IP = process.env.EC2_IP || "localhost";

const BASE_URL = `http://${EC2_IP}:${PORT}`;
const WS_URL = `ws://${EC2_IP}:${PORT}/ws`;

// Simple logger
const log = (...args) => console.log(`[${new Date().toISOString()}]`, ...args);

// -------------------------------
// MIDDLEWARE
// -------------------------------
app.use(express.json());
app.use(cors());

// -------------------------------
// MONGO CONNECT
// -------------------------------
const MONGO_URI = process.env.MONGO_URI;
if (!MONGO_URI) {
  log("⚠️  MONGO_URI is not set in .env - exiting");
  process.exit(1);
}

// Connect MongoDB
// mongoose.connect(process.env.MONGO_URI)
//     .then(() => console.log("✅ MongoDB Connected"))
//     .catch((err) => console.error("MongoDB connection error:", err));




// -------------------------------
// ROUTES
// -------------------------------
const deviceRoutes = require("./controllers/device.controller");
const authRoutes = require("./controllers/auth.controller");


app.use("/device", deviceRoutes);
app.use("/auth", authRoutes);

app.get("/", (req, res) => {
    res.send("Ionix Server is running 🚀");
});
app.get('/health', (req, res) => {
  try {
    const wsService = req.app.get('wsService');
    const scheduleService = req.app.get('scheduleService');

    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
    
    // Get WebSocket stats with safe fallbacks
    let wsStats = {
      connectedClients: 0,
      connectedDevices: 0,
      users: 0,
      devices: 0
    };

    if (wsService) {
      // Try to get enhanced stats first, then fall back to basic stats
      if (wsService.getDeviceStats) {
        wsStats = wsService.getDeviceStats();
      } else if (wsService.getStats) {
        const basicStats = wsService.getStats();
        wsStats = { ...wsStats, ...basicStats };
      }
      
      // Safely get actual connection counts
      if (wsService.esp32Devices) {
        wsStats.connectedESP32Devices = wsService.esp32Devices.size;
      }
      if (wsService.pendingDevices) {
        wsStats.pendingDevices = wsService.pendingDevices.size;
      }
      if (wsService.clients) {
        wsStats.connectedClients = wsService.clients.size;
      }
    }

    const healthResponse = {
      status: 'success',
      message: 'IoT Server Running',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      services: {
        database: dbStatus,
        websocket: {
          connectedClients: wsStats.connectedClients,
          connectedDevices: wsStats.connectedDevices,
          users: wsStats.users || 0,
          devices: wsStats.devices || 0,
          // New fields with safe access
          ...(wsStats.connectedESP32Devices !== undefined && { 
            connectedESP32Devices: wsStats.connectedESP32Devices 
          }),
          ...(wsStats.pendingDevices !== undefined && { 
            pendingDevices: wsStats.pendingDevices 
          })
        },
        scheduler: scheduleService ? 
          (scheduleService.getHealth ? scheduleService.getHealth() : { running: true }) 
          : { running: false }
      },
      version: '1.0.0'
    };

    res.json(healthResponse);
  } catch (error) {
    console.error('Health check error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Health check failed',
      error: error.message
    });
  }
});


// -------------------------------
// START SERVER
// -------------------------------

// Start server after database connection
const startServer = async () => {
  try {
    // Connect to database first
    console.log('🔗 Connecting to database...');
    await connectDB();
    
    // Start server
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Production IoT Server running on port ${PORT}`);
      console.log(`📍 Environment: ${process.env.NODE_ENV}`);
      console.log(`🔗 Health: http://0.0.0.0:${PORT}/health`);
      console.log(`🌐 External: http://16.171.209.89:${PORT}/health`);
      console.log(`🔐 Auth: http://0.0.0.0:${PORT}/api/auth`);
      console.log(`📱 Devices: http://0.0.0.0:${PORT}/api/devices`);
      console.log(`⏰ Schedules: http://0.0.0.0:${PORT}/api/schedules`);
      console.log(`🔍 Discovery: http://0.0.0.0:${PORT}/api/discover/devices`);
    });
    
    // Initialize services after server starts
  //  await initializeServices();
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Start the application
startServer();
// Enhanced graceful shutdown
const gracefulShutdown = async () => {
  console.log('🛑 Received shutdown signal, shutting down gracefully...');
  
  try {
    const scheduleService = app.get('scheduleService');
    if (scheduleService && scheduleService.stop) {
      scheduleService.stop();
      console.log('✅ Schedule service stopped');
    }

    // Close WebSocket connections safely
    const wsService = app.get('wsService');
    if (wsService && wsService.wss) {
      wsService.wss.close(() => {
        console.log('✅ WebSocket server closed');
      });
    }

    // Close HTTP server
    server.close(() => {
      console.log('✅ HTTP server closed');
      process.exit(0);
    });

    // Force close after 10 seconds
    setTimeout(() => {
      console.log('⚠️ Forcing shutdown after timeout');
      process.exit(1);
    }, 10000);

  } catch (error) {
    console.error('Error during graceful shutdown:', error);
    process.exit(1);
  }
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('🆘 Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('🆘 Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = { app, server };

// Start your websocket after DB init
require("./websocket")(server, log);
