import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Theme
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  // Devices - now using real structure
  List<Device> getDevices() {
    final String? devicesJson = _prefs.getString('devices');
    if (devicesJson == null) return _getDefaultDevices();
    
    try {
      final List<dynamic> decoded = jsonDecode(devicesJson);
      return decoded.map((d) => Device.fromJson(d)).toList();
    } catch (e) {
      return _getDefaultDevices();
    }
  }

  Future<void> saveDevices(List<Device> devices) async {
    final String encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _prefs.setString('devices', encoded);
  }

  // Rooms
  List<Room> getRooms() {
    final String? roomsJson = _prefs.getString('rooms');
    if (roomsJson == null) return _getDefaultRooms();
    
    try {
      final List<dynamic> decoded = jsonDecode(roomsJson);
      return decoded.map((r) => Room.fromJson(r)).toList();
    } catch (e) {
      return _getDefaultRooms();
    }
  }

  Future<void> saveRooms(List<Room> rooms) async {
    final String encoded = jsonEncode(rooms.map((r) => r.toJson()).toList());
    await _prefs.setString('rooms', encoded);
  }

  // User Profile
  String get userName => _prefs.getString('userName') ?? 'User';
  Future<void> setUserName(String value) => _prefs.setString('userName', value);

  String get userEmail => _prefs.getString('userEmail') ?? 'user@ionix.app';
  Future<void> setUserEmail(String value) => _prefs.setString('userEmail', value);

  // Server URL
  String get serverUrl => _prefs.getString('serverUrl') ?? 'http://localhost:3000';
  Future<void> setServerUrl(String value) => _prefs.setString('serverUrl', value);

  // Default devices matching your server log structure
  List<Device> _getDefaultDevices() {
    return [
      Device(
        id: 'device_1',
        name: 'Mohi jio 8949761393',
        ipAddress: '157.48.192.51',
        isOnline: true,
        lastSeen: DateTime.now(),
        systemStatus: SystemStatus(
          type: 'SYSTEM_STATUS',
          uptimeSeconds: 3077,
          wifiRssi: -55,
          lastCommand: 'None',
          relays: [
            Relay(
              relayId: 0,
              name: 'Mains fall',
              state: true,
              schedule: RelaySchedule(
                daily: DailySchedule(
                  enabled: true,
                  onTime: '13:28',
                  offTime: '13:29',
                ),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 1,
              name: 'Dg on',
              state: true,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 2,
              name: '48 cut off',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 3,
              name: 'cont Hold',
              state: true,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 4,
              name: 'Sps Rest',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 5,
              name: 'Dg cut off',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 6,
              name: 'Channel 1',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
            Relay(
              relayId: 7,
              name: 'Channel 2',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (i) => WeeklySchedule.empty()),
              ),
            ),
          ],
        ),
      ),
      Device(
        id: 'device_2',
        name: 'Sapper khari jio 9352229010',
        ipAddress: '157.48.192.52',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(seconds: 30)),
        systemStatus: SystemStatus(
          type: 'SYSTEM_STATUS',
          uptimeSeconds: 5234,
          wifiRssi: -62,
          lastCommand: 'None',
          relays: List.generate(
            10,
            (i) => Relay(
              relayId: i,
              name: 'Relay ${i + 1}',
              state: false,
              schedule: RelaySchedule(
                daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
                weekly: List.generate(7, (j) => WeeklySchedule.empty()),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Room> _getDefaultRooms() {
    return [
      Room(id: 'all', name: 'All', deviceIds: []),
      Room(id: 'livingroom', name: 'Livingroom', deviceIds: ['device_1']),
      Room(id: 'bedroom', name: 'Bedroom', deviceIds: ['device_2']),
      Room(id: 'other', name: 'Other', deviceIds: []),
    ];
  }
}