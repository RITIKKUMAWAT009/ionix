// services/device.service.js

let deviceSocket = null;

module.exports = {
    setDeviceSocket: (ws) => {
        deviceSocket = ws;
    },

    clearDeviceSocket: () => {
        deviceSocket = null;
    },


    isDeviceConnected: () => {
        return deviceSocket !== null;
    },

    sendCommand: (commandObj) => {
        if (!deviceSocket) {
            throw new Error("Device is not connected");
        }

        const payload = JSON.stringify(commandObj);
        deviceSocket.send(payload);
    }
};
