import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/device_model.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';

class HomeController extends GetxController {
  final _storage = Get.find<StorageService>();
  
  // Uncomment when API is ready
  // final _api = Get.find<ApiService>();
  
  final RxList<Device> devices = <Device>[].obs;
  final RxList<Room> rooms = <Room>[].obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxInt selectedBottomIndex = 0.obs;
  final RxString selectedRoomId = 'all'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
    loadRooms();
    // Start periodic status updates
    _startStatusPolling();
  }

  void loadDevices() {
    devices.value = _storage.getDevices();
  }

  void loadRooms() {
    rooms.value = _storage.getRooms();
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

  void toggleRelay(String deviceId, int relayId) async {
    final deviceIndex = devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex == -1) return;

    final device = devices[deviceIndex];
    final relayIndex = device.relays.indexWhere((r) => r.relayId == relayId);
    if (relayIndex == -1) return;

    final relay = device.relays[relayIndex];
    final newState = !relay.state;

    // Optimistic update
    final updatedRelays = List<Relay>.from(device.relays);
    updatedRelays[relayIndex] = relay.copyWith(state: newState);
    
    final updatedStatus = device.systemStatus?.copyWith(
      relays: updatedRelays,
    );
    
    devices[deviceIndex] = device.copyWith(systemStatus: updatedStatus);

    // Send command to server
    // Uncomment when API is ready
    /*
    final success = await _api.sendRelayCommand(
      deviceId: deviceId,
      relayId: relayId,
      state: newState,
    );

    if (!success) {
      // Revert on failure
      updatedRelays[relayIndex] = relay;
      final revertedStatus = device.systemStatus?.copyWith(relays: updatedRelays);
      devices[deviceIndex] = device.copyWith(systemStatus: revertedStatus);
      
      Get.snackbar(
        'Error',
        'Failed to toggle ${relay.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    */

    _storage.saveDevices(devices);

    Get.snackbar(
      'Command Sent',
      '${relay.displayName} ${newState ? "ON" : "OFF"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    selectedRoomId.value = rooms[index].id;
  }

  void selectBottomTab(int index) {
    selectedBottomIndex.value = index;
  }

  void addDevice() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
                hintText: '192.168.1.100',
              ),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Coming Soon',
                'Device addition feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<Device> get filteredDevices {
    if (selectedRoomId.value == 'all') {
      return devices;
    }
    
    final room = rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);
    if (room == null) return devices;
    
    if (room.deviceIds.isEmpty) return [];
    
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
    // Clean up resources
    super.onClose();
  }
}