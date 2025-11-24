// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../data/models/device_model.dart';
// import '../../data/services/storage_service.dart';
// import '../../data/services/api_service.dart';

// class HomeController extends GetxController {
//   final _storage = Get.find<StorageService>();
  
//   // Uncomment when API is ready
//   // final _api = Get.find<ApiService>();
  
//   final RxList<Device> devices = <Device>[].obs;
//   final RxList<Room> rooms = <Room>[].obs;
//   final RxInt selectedTabIndex = 0.obs;
//   final RxInt selectedBottomIndex = 0.obs;
//   final RxString selectedRoomId = 'all'.obs;
//   final RxBool isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadDevices();
//     loadRooms();
//     // Start periodic status updates
//     _startStatusPolling();
//   }

//   void loadDevices() {
//     devices.value = _storage.getDevices();
//   }

//   void loadRooms() {
//     rooms.value = _storage.getRooms();
//   }

//   void _startStatusPolling() {
//     // Poll for device status every 10 seconds
//     // Uncomment when API is ready
//     /*
//     ever(devices, (_) => _storage.saveDevices(devices));
    
//     Timer.periodic(const Duration(seconds: 10), (timer) async {
//       if (!isLoading.value) {
//         await refreshDevices();
//       }
//     });
//     */
//   }

//   Future<void> refreshDevices() async {
//     // Uncomment when API is ready
//     /*
//     try {
//       isLoading.value = true;
//       final updatedDevices = await _api.fetchDevices();
//       if (updatedDevices.isNotEmpty) {
//         devices.value = updatedDevices;
//         _storage.saveDevices(devices);
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to refresh devices',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//     */
//   }

//   void toggleRelay(String deviceId, int relayId) async {
//     final deviceIndex = devices.indexWhere((d) => d.id == deviceId);
//     if (deviceIndex == -1) return;

//     final device = devices[deviceIndex];
//     final relayIndex = device.relays.indexWhere((r) => r.relayId == relayId);
//     if (relayIndex == -1) return;

//     final relay = device.relays[relayIndex];
//     final newState = !relay.state;

//     // Optimistic update
//     final updatedRelays = List<Relay>.from(device.relays);
//     updatedRelays[relayIndex] = relay.copyWith(state: newState);
    
//     final updatedStatus = device.systemStatus?.copyWith(
//       relays: updatedRelays,
//     );
    
//     devices[deviceIndex] = device.copyWith(systemStatus: updatedStatus);

//     // Send command to server
//     // Uncomment when API is ready
//     /*
//     final success = await _api.sendRelayCommand(
//       deviceId: deviceId,
//       relayId: relayId,
//       state: newState,
//     );

//     if (!success) {
//       // Revert on failure
//       updatedRelays[relayIndex] = relay;
//       final revertedStatus = device.systemStatus?.copyWith(relays: updatedRelays);
//       devices[deviceIndex] = device.copyWith(systemStatus: revertedStatus);
      
//       Get.snackbar(
//         'Error',
//         'Failed to toggle ${relay.displayName}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     */

//     _storage.saveDevices(devices);

//     Get.snackbar(
//       'Command Sent',
//       '${relay.displayName} ${newState ? "ON" : "OFF"}',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   void selectTab(int index) {
//     selectedTabIndex.value = index;
//     selectedRoomId.value = rooms[index].id;
//   }

//   void selectBottomTab(int index) {
//     selectedBottomIndex.value = index;
//   }

//   void addDevice() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Add Device'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Device Name',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {},
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'IP Address',
//                 border: OutlineInputBorder(),
//                 hintText: '192.168.1.100',
//               ),
//               onChanged: (value) {},
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               Get.snackbar(
//                 'Coming Soon',
//                 'Device addition feature will be available soon',
//                 snackPosition: SnackPosition.BOTTOM,
//               );
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Device> get filteredDevices {
//     if (selectedRoomId.value == 'all') {
//       return devices;
//     }
    
//     final room = rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);
//     if (room == null) return devices;
    
//     if (room.deviceIds.isEmpty) return [];
    
//     return devices.where((d) => room.deviceIds.contains(d.id)).toList();
//   }

//   String get selectedRoomName {
//     final room = rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);
//     return room?.name ?? 'All';
//   }

//   int get totalDevices => devices.length;
//   int get onlineDevices => devices.where((d) => d.isOnline).length;
//   int get totalRelays => devices.fold(0, (sum, d) => sum + d.relayCount);
//   int get activeRelays => devices.fold(0, (sum, d) => sum + d.activeRelayCount);

//   @override
//   void onClose() {
//     // Clean up resources
//     super.onClose();
//   }
// }



import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/device_model.dart';
import '../../data/services/websocket_service.dart';

// Make sure you've registered WebSocketService in Get:
// Get.put(WebSocketService(url: 'ws://16.171.209.89:3000/ws'));

class HomeController extends GetxController {
  final WebSocketService _ws = Get.find<WebSocketService>();

  final RxList<Device> devices = <Device>[].obs;
  // rooms still optional - you can fetch via API later or keep static
  final RxList<Room> rooms = <Room>[].obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxInt selectedBottomIndex = 0.obs;
  final RxString selectedRoomId = 'all'.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  @override
  void onInit() {
    super.onInit();

    // Connect websocket (auto-reconnect inside service)
    _ws.connect();

    // Listen incoming WS messages
    _wsSub = _ws.messages.listen(_handleWsMessage, onError: (e) {
      // handle errors if needed
    });

    // Fetch devices once connected / immediately
    // If connection not yet ready, the service will reconnect and you can call getDevices again
    Future.delayed(Duration(milliseconds: 300), () {
      _ws.getDevices();
    });
  }


  void selectTab(int index) {
    selectedTabIndex.value = index;
    selectedRoomId.value = rooms[index].id;
  }

  // ---------------------------
  // WebSocket message handler
  // ---------------------------
  void _handleWsMessage(Map<String, dynamic> msg) {
    final event = msg['event'] ?? msg['type']; // server uses event names for mobile
    switch (event) {
      case 'devicesList':
        _handleDevicesList(msg['devices']);
        break;

      case 'deviceUpdated':
        _handleDeviceUpdated(msg['device']);
        break;

      case 'deviceOnline':
        _handleDeviceOnline(msg['deviceId']);
        break;

      case 'deviceOffline':
        _handleDeviceOffline(msg['deviceId']);
        break;

      case 'relayUpdated':
        _handleRelayUpdated(msg['data'] ?? msg);
        break;

      case 'devicesListError':
        // optional: show error
        break;

      default:
        // ignore unknown events or handle logs
        break;
    }
  }

  // ---------------------------
  // Helpers: convert server payload -> Device model
  // ---------------------------
  Device _buildDeviceFromServer(Map<String, dynamic> d) {
    final id = d['deviceId']?.toString() ?? d['id']?.toString() ?? '';
    final name = d['name'] ?? id;
    final ip = d['ip'] ?? d['ipAddress'] ?? '';
    final statusStr = (d['status'] ?? d['state'] ?? '').toString();
    final isOnline = statusStr == 'online' || statusStr == 'true' || d['isOnline'] == true;

    // Build SystemStatus if present
    SystemStatus? sys;
    final uptime = d['uptime'] ?? d['uptime_s'] ?? d['systemStatus']?['uptime_s'];
    final wifi = d['wifi_rssi'] ?? d['wifi_rssi'] ?? d['systemStatus']?['wifi_rssi'];
    final lastCmd = d['last_command'] ?? d['lastCommand'] ?? d['systemStatus']?['last_command'];
    final relaysJson = d['relays'] ?? d['systemStatus']?['relays'] ?? [];

    if (relaysJson != null) {
      final relaysList = (relaysJson as List).map((r) => Relay.fromJson(Map<String, dynamic>.from(r))).toList();
      sys = SystemStatus(
        type: 'SYSTEM_STATUS',
        uptimeSeconds: (uptime is int) ? uptime : (uptime is String ? int.tryParse(uptime) ?? 0 : 0),
        wifiRssi: (wifi is int) ? wifi : (wifi is String ? int.tryParse(wifi) ?? 0 : 0),
        lastCommand: lastCmd ?? 'None',
        relays: relaysList,
      );
    }

    return Device(
      id: id,
      name: name,
      ipAddress: ip,
      isOnline: isOnline,
      lastSeen: d['lastSeen'] != null ? DateTime.tryParse(d['lastSeen'].toString()) : null,
      systemStatus: sys,
    );
  }

    void selectBottomTab(int index) {
    selectedBottomIndex.value = index;
  }


  // ---------------------------
  // Event handlers
  // ---------------------------
  void _handleDevicesList(dynamic raw) {
    if (raw == null) return;
    final list = (raw as List).map((e) => _buildDeviceFromServer(Map<String, dynamic>.from(e))).toList();
    devices.value = list;
  }

  void _handleDeviceUpdated(dynamic raw) {
    if (raw == null) return;
    final updated = _buildDeviceFromServer(Map<String, dynamic>.from(raw));
    final idx = devices.indexWhere((d) => d.id == updated.id);
    if (idx == -1) {
      devices.add(updated);
    } else {
      devices[idx] = updated;
    }
  }

  void _handleDeviceOnline(String deviceId) {
    final idx = devices.indexWhere((d) => d.id == deviceId);
    if (idx != -1) {
      final d = devices[idx];
      devices[idx] = d.copyWith(isOnline: true, lastSeen: DateTime.now());
    } else {
      // fetch full list if unknown
      _ws.getDevices();
    }
  }

  void _handleDeviceOffline(String deviceId) {
    final idx = devices.indexWhere((d) => d.id == deviceId);
    if (idx != -1) {
      final d = devices[idx];
      devices[idx] = d.copyWith(isOnline: false, lastSeen: DateTime.now());
    }
  }

  void _handleRelayUpdated(dynamic raw) {
    // raw should contain deviceId, relayId, state
    if (raw == null) return;
    final deviceId = raw['deviceId'] ?? raw['device_id'] ?? raw['device'];
    final relayId = raw['relayId'] ?? raw['relay_id'] ?? raw['relay'];
    final state = raw['state'] ?? raw['value'];

    if (deviceId == null || relayId == null) return;

    final idx = devices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;

    final dev = devices[idx];
    final relays = List<Relay>.from(dev.relays);
    final rIndex = relays.indexWhere((r) => r.relayId == relayId);
    if (rIndex != -1) {
      relays[rIndex] = relays[rIndex].copyWith(state: state == true || state == 1);
      final sys = dev.systemStatus?.copyWith(relays: relays) ?? SystemStatus(type: 'SYSTEM_STATUS', uptimeSeconds: 0, wifiRssi: 0, lastCommand: 'None', relays: relays);
      devices[idx] = dev.copyWith(systemStatus: sys);
    }
  }

  // ---------------------------
  // Public actions invoked by UI
  // ---------------------------
  void toggleRelay(String deviceId, int relayId) {
    // Optimistic update: flip locally
    final idx = devices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;
    final dev = devices[idx];
    final relays = List<Relay>.from(dev.relays);
    final rIdx = relays.indexWhere((r) => r.relayId == relayId);
    if (rIdx == -1) return;
    final old = relays[rIdx];
    final newState = !old.state;
    relays[rIdx] = old.copyWith(state: newState);
    final sys = dev.systemStatus?.copyWith(relays: relays) ?? SystemStatus(type: 'SYSTEM_STATUS', uptimeSeconds: 0, wifiRssi: 0, lastCommand: 'None', relays: relays);
    devices[idx] = dev.copyWith(systemStatus: sys);

    // Send command over websocket (server will forward to device)
    _ws.toggleRelay(deviceId: deviceId, relayId: relayId);
  }

  void requestStatus(String deviceId) {
    _ws.requestStatus(deviceId: deviceId);
  }

  void setTimer(String deviceId, int relayId, int seconds) {
    _ws.setTimer(deviceId: deviceId, relayId: relayId, seconds: seconds);
  }

  void setSchedule(String deviceId, int relayId, Map<String, dynamic> scheduleData) {
    _ws.setSchedule(deviceId: deviceId, relayId: relayId, scheduleData: scheduleData);
  }

  // ---------------------------
  // Filtering & helpers
  // ---------------------------
  List<Device> get filteredDevices {
    if (selectedRoomId.value == 'all') return devices;
    final room = rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);
    if (room == null) return devices;
    return devices.where((d) => room.deviceIds.contains(d.id)).toList();
  }

  String get selectedRoomName {
    final room = rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);
    return room?.name ?? 'All';
  }

  int get totalDevices => devices.length;
  int get onlineDevices => devices.where((d) => d.isOnline).length;
  int get totalRelays => devices.fold(0, (sum, d) => sum + d.relayCount);
  int get activeRelays => devices.fold(0, (sum, d) => sum + d.activeRelayCount);

  @override
  void onClose() {
    _wsSub?.cancel();
    super.onClose();
  }



void _startStatusPolling() {
    // Poll for device status every 10 seconds
    // Uncomment when API is ready
    /*
    ever(devices, (_) => _storage.saveDevices(devices));
    
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!isLoading.value) {
        await refreshDevices();
      }
    });
    */
}
  

  Future<void> refreshDevices() async {
    // Uncomment when API is ready
    /*
    try {
      isLoading.value = true;
      final updatedDevices = await _api.fetchDevices();
      if (updatedDevices.isNotEmpty) {
        devices.value = updatedDevices;
        _storage.saveDevices(devices);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh devices',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
    */
  }
}