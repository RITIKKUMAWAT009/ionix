# Ionix - Premium IoT Device Management App

A professional Flutter application for managing IoT relay devices with real-time WebSocket communication, built using GetX state management and clean architecture.

## Features

✨ **Real-Time Device Management**
- WebSocket-based real-time updates
- System status monitoring (uptime, WiFi RSSI)
- Heartbeat detection
- Up to 10 relays per device
- Individual relay control

🎛️ **Advanced Relay Control**
- Toggle individual relays
- Daily and weekly scheduling with full UI
- Countdown timers
- Custom relay naming
- Visual state indicators
- Long-press menu for quick actions
- Schedule preview and management

📊 **Device Monitoring**
- Online/offline status
- WiFi signal strength
- System uptime tracking
- Last command history
- Active relay count

🎨 **Modern UI/UX**
- Light and Dark mode support
- Premium, professional design
- Real-time status updates
- Responsive layout
- Pull-to-refresh

👤 **User Features**
- User profile management
- Customizable settings
- Theme preferences
- Room-based organization

🏗️ **Architecture**
- Clean Architecture principles
- GetX state management
- Reactive programming with Rx
- Service layer abstraction
- Modular structure

## Data Structure

### Device Message Types

#### System Status (from your server log)
```json
{
  "type": "SYSTEM_STATUS",
  "uptime_s": 3077,
  "wifi_rssi": -55,
  "last_command": "None",
  "relays": [
    {
      "relay_id": 0,
      "name": "Relay 1",
      "state": false,
      "countdown_s": 0,
      "schedule": {
        "daily": {
          "en": true,
          "on": "13:28",
          "off": "13:29"
        },
        "weekly": [
          {
            "en": true,
            "on": "13:30",
            "off": "01:31"
          }
          // ... 7 entries for each day
        ]
      }
    }
    // ... up to 10 relays
  ]
}
```

#### Heartbeat
```json
{
  "type": "HEARTBEAT"
}
```

### Relay Command Structure
```json
{
  "type": "RELAY_COMMAND",
  "device_id": "device_1",
  "relay_id": 0,
  "state": true,
  "countdown": 30  // optional
}
```

## Project Structure

```
lib/
├── app/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart         # Theme configuration
│   ├── data/
│   │   ├── models/
│   │   │   └── device_model.dart      # Device, Relay, Schedule models
│   │   └── services/
│   │       ├── storage_service.dart   # Local storage
│   │       ├── theme_service.dart     # Theme management
│   │       └── api_service.dart       # API & WebSocket communication
│   ├── modules/
│   │   ├── home/
│   │   │   ├── home_binding.dart
│   │   │   ├── home_controller.dart
│   │   │   └── home_view.dart
│   │   ├── profile/
│   │   │   ├── profile_binding.dart
│   │   │   ├── profile_controller.dart
│   │   │   └── profile_view.dart
│   │   └── settings/
│   │       ├── settings_binding.dart
│   │       ├── settings_controller.dart
│   │       └── settings_view.dart
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Running IoT server (WebSocket endpoint)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ionix.git
cd ionix
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure your server URL in `api_service.dart`:
```dart
final String baseUrl = 'http://your-server-url:3000';
```

4. Run the app:
```bash
flutter run
```

## Configuration

### Server Connection

Update the base URL in `lib/app/data/services/api_service.dart`:

```dart
final String baseUrl = 'http://192.168.1.100:3000';
```

### WebSocket Setup

To enable real-time updates via WebSocket:

1. Uncomment `web_socket_channel` in `pubspec.yaml`
2. Uncomment WebSocket code in `api_service.dart`
3. Update WebSocket URL to match your server

## API Integration

### REST Endpoints

The app expects the following REST endpoints:

- `GET /api/devices` - List all devices
- `GET /api/devices/:id/status` - Get device status
- `POST /api/devices/:id/relay` - Control relay
- `PATCH /api/devices/:id/relay/:relayId` - Update relay settings
- `POST /api/devices` - Add new device
- `DELETE /api/devices/:id` - Remove device

### WebSocket Events

- **Incoming**: `SYSTEM_STATUS`, `HEARTBEAT`
- **Outgoing**: `RELAY_COMMAND`, `GET_STATUS`

## Features Breakdown

### Device Management
- Automatic device discovery
- Add/remove devices
- Real-time status updates
- Group devices by rooms
- Device offline detection

### Relay Control
- Individual relay toggle
- Bulk operations
- Schedule management (Daily & Weekly)
- Visual schedule editor with time picker
- Countdown timers
- State persistence
- Long-press context menu

### Monitoring
- WiFi signal quality indicator
- System uptime display
- Last command tracking
- Active relay count
- Statistics dashboard

### Theme System
- Light and Dark themes
- Smooth theme transitions
- Persistent theme preference
- Premium color schemes

## Device Models

### Device Class
```dart
Device(
  id: 'device_1',
  name: 'Device Name',
  ipAddress: '192.168.1.100',
  isOnline: true,
  systemStatus: SystemStatus(...)
)
```

### Relay Class
```dart
Relay(
  relayId: 0,
  name: 'Relay 1',
  state: false,
  countdownSeconds: 0,
  schedule: RelaySchedule(...)
)
```

## Customization

### Adding Default Devices

Modify `storage_service.dart` in `_getDefaultDevices()` method to match your actual devices.

### Customizing Theme

Edit `app_theme.dart` to modify colors:

```dart
static const Color primaryLight = Color(0xFF4A90E2);
static const Color primaryDark = Color(0xFF4A90E2);
```

## Future Enhancements

- [x] Real device data structure
- [x] Relay scheduling support with full UI
- [x] Daily and Weekly schedule management
- [x] System monitoring
- [ ] WebSocket real-time updates
- [ ] Device analytics dashboard
- [ ] Scene automation
- [ ] Voice control integration
- [ ] Multi-user support with authentication
- [ ] Cloud sync
- [ ] Push notifications
- [ ] Energy monitoring
- [ ] Historical data graphs
- [ ] Widget support
- [ ] Relay countdown timer UI
- [ ] Bulk relay operations

## Troubleshooting

### Devices Not Appearing
1. Check server URL in `api_service.dart`
2. Verify server is running and accessible
3. Check network connectivity
4. Review server logs for errors

### Relay Commands Not Working
1. Verify device is online
2. Check server endpoint configuration
3. Review API response format
4. Enable debug logging in Dio

### WebSocket Connection Issues
1. Ensure WebSocket endpoint is correct
2. Check firewall settings
3. Verify WebSocket server is running
4. Review connection logs

## Dependencies

- **get**: State management and routing
- **google_fonts**: Typography
- **shared_preferences**: Local storage
- **dio**: HTTP client for REST API
- **web_socket_channel**: WebSocket support (optional)
- **intl**: Internationalization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For support, email support@ionix.app or open an issue on GitHub.

---

Built with ❤️ using Flutter and GetX

**Server Compatibility**: Designed to work with ESP32/ESP8266 relay controllers with WebSocket support.