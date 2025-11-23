// Device Models based on actual server data structure

class Device {
  final String id;
  final String name;
  final String ipAddress;
  final bool isOnline;
  final DateTime? lastSeen;
  final SystemStatus? systemStatus;

  Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.isOnline = false,
    this.lastSeen,
    this.systemStatus,
  });

  Device copyWith({
    String? id,
    String? name,
    String? ipAddress,
    bool? isOnline,
    DateTime? lastSeen,
    SystemStatus? systemStatus,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      systemStatus: systemStatus ?? this.systemStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'systemStatus': systemStatus?.toJson(),
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      systemStatus: json['systemStatus'] != null 
          ? SystemStatus.fromJson(json['systemStatus']) 
          : null,
    );
  }

  List<Relay> get relays => systemStatus?.relays ?? [];
  int get relayCount => relays.length;
  int get activeRelayCount => relays.where((r) => r.state).length;
}

class SystemStatus {
  final String type;
  final int uptimeSeconds;
  final int wifiRssi;
  final String lastCommand;
  final List<Relay> relays;

  SystemStatus({
    required this.type,
    required this.uptimeSeconds,
    required this.wifiRssi,
    required this.lastCommand,
    required this.relays,
  });

  String get uptimeFormatted {
    final hours = uptimeSeconds ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  String get wifiSignalQuality {
    if (wifiRssi >= -50) return 'Excellent';
    if (wifiRssi >= -60) return 'Good';
    if (wifiRssi >= -70) return 'Fair';
    return 'Poor';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'uptime_s': uptimeSeconds,
      'wifi_rssi': wifiRssi,
      'last_command': lastCommand,
      'relays': relays.map((r) => r.toJson()).toList(),
    };
  }

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      type: json['type'] ?? 'SYSTEM_STATUS',
      uptimeSeconds: json['uptime_s'] ?? 0,
      wifiRssi: json['wifi_rssi'] ?? 0,
      lastCommand: json['last_command'] ?? 'None',
      relays: (json['relays'] as List?)
          ?.map((r) => Relay.fromJson(r))
          .toList() ?? [],
    );
  }

  SystemStatus copyWith({
    String? type,
    int? uptimeSeconds,
    int? wifiRssi,
    String? lastCommand,
    List<Relay>? relays,
  }) {
    return SystemStatus(
      type: type ?? this.type,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      wifiRssi: wifiRssi ?? this.wifiRssi,
      lastCommand: lastCommand ?? this.lastCommand,
      relays: relays ?? this.relays,
    );
  }
}

class Relay {
  final int relayId;
  final String name;
  final bool state;
  final int countdownSeconds;
  final RelaySchedule schedule;

  Relay({
    required this.relayId,
    required this.name,
    required this.state,
    this.countdownSeconds = 0,
    required this.schedule,
  });

  Relay copyWith({
    int? relayId,
    String? name,
    bool? state,
    int? countdownSeconds,
    RelaySchedule? schedule,
  }) {
    return Relay(
      relayId: relayId ?? this.relayId,
      name: name ?? this.name,
      state: state ?? this.state,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      schedule: schedule ?? this.schedule,
    );
  }

  String get displayName {
    if (name.toLowerCase().contains('relay')) {
      return name;
    }
    return 'Relay ${relayId + 1}';
  }

  bool get hasCountdown => countdownSeconds > 0;
  bool get hasActiveSchedule => schedule.hasActiveSchedule;

  Map<String, dynamic> toJson() {
    return {
      'relay_id': relayId,
      'name': name,
      'state': state,
      'countdown_s': countdownSeconds,
      'schedule': schedule.toJson(),
    };
  }

  factory Relay.fromJson(Map<String, dynamic> json) {
    return Relay(
      relayId: json['relay_id'] ?? 0,
      name: json['name'] ?? 'Relay',
      state: json['state'] ?? false,
      countdownSeconds: json['countdown_s'] ?? 0,
      schedule: RelaySchedule.fromJson(json['schedule'] ?? {}),
    );
  }
}

class RelaySchedule {
  final DailySchedule daily;
  final List<WeeklySchedule> weekly;

  RelaySchedule({
    required this.daily,
    required this.weekly,
  });

  bool get hasActiveSchedule {
    if (daily.enabled) return true;
    return weekly.any((w) => w.enabled);
  }

  Map<String, dynamic> toJson() {
    return {
      'daily': daily.toJson(),
      'weekly': weekly.map((w) => w.toJson()).toList(),
    };
  }

  factory RelaySchedule.fromJson(Map<String, dynamic> json) {
    return RelaySchedule(
      daily: DailySchedule.fromJson(json['daily'] ?? {}),
      weekly: (json['weekly'] as List?)
          ?.map((w) => WeeklySchedule.fromJson(w))
          .toList() ?? List.generate(7, (i) => WeeklySchedule.empty()),
    );
  }
}

class DailySchedule {
  final bool enabled;
  final String onTime;
  final String offTime;

  DailySchedule({
    required this.enabled,
    required this.onTime,
    required this.offTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'en': enabled,
      'on': onTime,
      'off': offTime,
    };
  }

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      enabled: json['en'] ?? false,
      onTime: json['on'] ?? '00:00',
      offTime: json['off'] ?? '00:00',
    );
  }
}

class WeeklySchedule {
  final bool enabled;
  final String onTime;
  final String offTime;

  WeeklySchedule({
    required this.enabled,
    required this.onTime,
    required this.offTime,
  });

  factory WeeklySchedule.empty() {
    return WeeklySchedule(
      enabled: false,
      onTime: '00:00',
      offTime: '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': enabled,
      'on': onTime,
      'off': offTime,
    };
  }

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      enabled: json['en'] ?? false,
      onTime: json['on'] ?? '00:00',
      offTime: json['off'] ?? '00:00',
    );
  }
}

// WebSocket Message Types
class DeviceMessage {
  final String type;
  final Map<String, dynamic>? data;

  DeviceMessage({
    required this.type,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (data != null) ...data!,
    };
  }

  factory DeviceMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = Map<String, dynamic>.from(json)..remove('type');
    return DeviceMessage(type: type, data: data);
  }

  bool get isHeartbeat => type == 'HEARTBEAT';
  bool get isSystemStatus => type == 'SYSTEM_STATUS';
}

// Command Models
class RelayCommand {
  final String deviceId;
  final int relayId;
  final bool state;
  final int? countdown;

  RelayCommand({
    required this.deviceId,
    required this.relayId,
    required this.state,
    this.countdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'RELAY_COMMAND',
      'device_id': deviceId,
      'relay_id': relayId,
      'state': state,
      if (countdown != null) 'countdown': countdown,
    };
  }
}

class Room {
  final String id;
  final String name;
  final List<String> deviceIds;

  Room({
    required this.id,
    required this.name,
    required this.deviceIds,
  });

  Room copyWith({
    String? id,
    String? name,
    List<String>? deviceIds,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceIds: deviceIds ?? this.deviceIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceIds': deviceIds,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      deviceIds: List<String>.from(json['deviceIds'] ?? []),
    );
  }
}