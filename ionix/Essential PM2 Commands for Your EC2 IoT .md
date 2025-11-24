Essential PM2 Commands for Your EC2 IoT Server
1. Connect to EC2 & Navigate to Your Project
bash
# Connect to EC2
ssh -i /home/ritik/Downloads/iot-serverpod-key.pem ec2-user@16.171.209.89

# Navigate to your project
cd iotrix/iot-app-server
2. Start/Stop Your Server
bash
# Start your IoT server
pm2 start src/server.js --name "iot-server"

# Stop your server
pm2 stop iot-server

# Restart your server
pm2 restart iot-server
3. Check Server Status
bash
# Check if server is running
pm2 status

# See detailed info
pm2 show iot-server

# Monitor in real-time
pm2 monit
4. View Logs
bash
# See all logs in real-time
pm2 logs iot-server

# See only last 50 lines
pm2 logs iot-server --lines 50

# See only errors
pm2 logs iot-server --error

# Stop watching logs
Ctrl + C
5. Server Management
bash
# If server crashes, it auto-restarts
# But you can manually restart:
pm2 restart iot-server

# Delete the process (stops and removes from PM2)
pm2 delete iot-server

# Start again after deletion
pm2 start src/server.js --name "iot-server"
6. Setup Auto-Start on Boot (Already Done)
bash
# Check if auto-start is configured
pm2 startup

# Save current running processes
pm2 save
7. Update Your Code & Redeploy
bash
# Stop server
pm2 stop iot-server

# Pull latest code (if using git)
git pull

# Install new dependencies
npm install

# Start server again
pm2 start iot-server
Quick Command Reference Card:
Command	Purpose
pm2 status	Check if server is running
pm2 start iot-server	Start your IoT server
pm2 stop iot-server	Stop your server
pm2 restart iot-server	Restart your server
pm2 logs iot-server	View server logs
pm2 delete iot-server	Stop and remove from PM2
Common Scenarios:
Scenario 1: Server crashed or stopped
bash
pm2 status                 # Check if it's running
pm2 start iot-server       # Start if stopped
Scenario 2: Deployed new code
bash
pm2 stop iot-server
# Update your code...
pm2 start iot-server
Scenario 3: Check what's wrong
bash
pm2 logs iot-server        # Check error logs
pm2 status                 # Check if running
pm2 show iot-server        # Detailed info
Scenario 4: Complete shutdown
bash
pm2 stop iot-server        # Stop but keep in PM2
# OR
pm2 delete iot-server      # Stop and remove completely
Your server will automatically restart if it crashes, so you don't need to manually start it every time! 🚀