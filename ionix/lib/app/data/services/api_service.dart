import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/device_model.dart';

class ApiService extends GetxService {
  late Dio _dio;
  
  // WebSocket connection would go here in production
  // For now, we'll use HTTP polling or REST API
  
  final String baseUrl = 'http://16.171.209.89:3000'; // Update with your server URL
  
  final RxList<Device> devices = <Device>[].obs;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Fetch all devices
  Future<List<Device>> fetchDevices() async {
    try {
      final response = await _dio.get('/api/devices');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        devices.value = data.map((d) => Device.fromJson(d)).toList();
        return devices;
      }
      return [];
    } catch (e) {
      print('Error fetching devices: $e');
      return [];
    }
  }

  // Fetch device status
  Future<SystemStatus?> fetchDeviceStatus(String deviceId) async {
    try {
      final response = await _dio.get('/api/devices/$deviceId/status');
      
      if (response.statusCode == 200) {
        return SystemStatus.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching device status: $e');
      return null;
    }
  }

  // Send relay command
  Future<bool> sendRelayCommand({
    required String deviceId,
    required int relayId,
    required bool state,
    int? countdown,
  }) async {
    try {
      final command = RelayCommand(
        deviceId: deviceId,
        relayId: relayId,
        state: state,
        countdown: countdown,
      );

      final response = await _dio.post(
        '/api/devices/$deviceId/relay',
        data: command.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending relay command: $e');
      return false;
    }
  }

  // Update relay name
  Future<bool> updateRelayName({
    required String deviceId,
    required int relayId,
    required String name,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/devices/$deviceId/relay/$relayId',
        data: {'name': name},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating relay name: $e');
      return false;
    }
  }

  // Update relay schedule
  Future<bool> updateRelaySchedule({
    required String deviceId,
    required int relayId,
    required RelaySchedule schedule,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/devices/$deviceId/relay/$relayId/schedule',
        data: schedule.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating relay schedule: $e');
      return false;
    }
  }

  // Add new device
  Future<Device?> addDevice({
    required String name,
    required String ipAddress,
  }) async {
    try {
      final response = await _dio.post(
        '/api/devices',
        data: {
          'name': name,
          'ipAddress': ipAddress,
        },
      );

      if (response.statusCode == 201) {
        final device = Device.fromJson(response.data);
        devices.add(device);
        return device;
      }
      return null;
    } catch (e) {
      print('Error adding device: $e');
      return null;
    }
  }

  // Remove device
  Future<bool> removeDevice(String deviceId) async {
    try {
      final response = await _dio.delete('/api/devices/$deviceId');
      
      if (response.statusCode == 200) {
        devices.removeWhere((d) => d.id == deviceId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing device: $e');
      return false;
    }
  }

  // WebSocket connection (for real-time updates)
  // This would be implemented using web_socket_channel package
  /*
  void connectWebSocket() {
    try {
      final wsUrl = baseUrl.replaceFirst('http', 'ws');
      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws'));
      
      _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onDone: () {
          isConnected.value = false;
          // Attempt reconnection
          Future.delayed(Duration(seconds: 5), connectWebSocket);
        },
        onError: (error) {
          print('WebSocket error: $error');
          isConnected.value = false;
        },
      );
      
      isConnected.value = true;
    } catch (e) {
      print('Error connecting WebSocket: $e');
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final deviceMessage = DeviceMessage.fromJson(data);
      
      if (deviceMessage.isSystemStatus) {
        _updateDeviceStatus(data);
      } else if (deviceMessage.isHeartbeat) {
        _updateDeviceHeartbeat(data);
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _updateDeviceStatus(Map<String, dynamic> data) {
    // Update device status in the devices list
    final deviceId = data['device_id'];
    final status = SystemStatus.fromJson(data);
    
    final index = devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      devices[index] = devices[index].copyWith(
        systemStatus: status,
        isOnline: true,
        lastSeen: DateTime.now(),
      );
    }
  }

  void _updateDeviceHeartbeat(Map<String, dynamic> data) {
    final deviceId = data['device_id'];
    final index = devices.indexWhere((d) => d.id == deviceId);
    
    if (index != -1) {
      devices[index] = devices[index].copyWith(
        isOnline: true,
        lastSeen: DateTime.now(),
      );
    }
  }

  void disconnect() {
    _channel?.sink.close();
    isConnected.value = false;
  }
  */
}