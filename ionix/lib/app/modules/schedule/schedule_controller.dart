import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionix/app/modules/home/home_controller.dart';
import '../../data/models/device_model.dart';
import '../../data/services/storage_service.dart';
// import '../../data/services/api_service.dart'; // Uncomment when API is ready

class ScheduleController extends GetxController {
  final _storage = Get.find<StorageService>();
  // final _api = Get.find<ApiService>(); // Uncomment when API is ready

  late final Device device;
  late final Relay relay;

  final Rx<RelaySchedule> schedule = RelaySchedule(
    daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
    weekly: List.generate(7, (i) => WeeklySchedule.empty()),
  ).obs;

  final RxInt selectedTab = 0.obs; // 0 = Daily, 1 = Weekly
  final RxInt selectedWeekday = 0.obs;

  final RxList<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments passed from previous screen
    final args = Get.arguments;
    device = args['device'] as Device;
    relay = args['relay'] as Relay;
    
    // Initialize with current schedule
    schedule.value = relay.schedule;
  }

  // Daily Schedule Methods
  void toggleDailySchedule(bool enabled) {
    schedule.value = RelaySchedule(
      daily: DailySchedule(
        enabled: enabled,
        onTime: schedule.value.daily.onTime,
        offTime: schedule.value.daily.offTime,
      ),
      weekly: schedule.value.weekly,
    );
  }

  void setDailyOnTime(TimeOfDay time) {
    schedule.value = RelaySchedule(
      daily: DailySchedule(
        enabled: schedule.value.daily.enabled,
        onTime: _formatTime(time),
        offTime: schedule.value.daily.offTime,
      ),
      weekly: schedule.value.weekly,
    );
  }

  void setDailyOffTime(TimeOfDay time) {
    schedule.value = RelaySchedule(
      daily: DailySchedule(
        enabled: schedule.value.daily.enabled,
        onTime: schedule.value.daily.onTime,
        offTime: _formatTime(time),
      ),
      weekly: schedule.value.weekly,
    );
  }

  // Weekly Schedule Methods
  void toggleWeeklySchedule(int dayIndex, bool enabled) {
    final updatedWeekly = List<WeeklySchedule>.from(schedule.value.weekly);
    updatedWeekly[dayIndex] = WeeklySchedule(
      enabled: enabled,
      onTime: schedule.value.weekly[dayIndex].onTime,
      offTime: schedule.value.weekly[dayIndex].offTime,
    );
    
    schedule.value = RelaySchedule(
      daily: schedule.value.daily,
      weekly: updatedWeekly,
    );
  }

  void setWeeklyOnTime(int dayIndex, TimeOfDay time) {
    final updatedWeekly = List<WeeklySchedule>.from(schedule.value.weekly);
    updatedWeekly[dayIndex] = WeeklySchedule(
      enabled: schedule.value.weekly[dayIndex].enabled,
      onTime: _formatTime(time),
      offTime: schedule.value.weekly[dayIndex].offTime,
    );
    
    schedule.value = RelaySchedule(
      daily: schedule.value.daily,
      weekly: updatedWeekly,
    );
  }

  void setWeeklyOffTime(int dayIndex, TimeOfDay time) {
    final updatedWeekly = List<WeeklySchedule>.from(schedule.value.weekly);
    updatedWeekly[dayIndex] = WeeklySchedule(
      enabled: schedule.value.weekly[dayIndex].enabled,
      onTime: schedule.value.weekly[dayIndex].onTime,
      offTime: _formatTime(time),
    );
    
    schedule.value = RelaySchedule(
      daily: schedule.value.daily,
      weekly: updatedWeekly,
    );
  }

  void selectWeekday(int index) {
    selectedWeekday.value = index;
    update();
  }

    void selectTab(int index) {
    selectedTab.value = index;
  }

  // Delete schedule
  void deleteSchedule() {
    Get.defaultDialog(
      title: 'Delete Schedule',
      middleText: 'Are you sure you want to delete all schedules for this relay?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        schedule.value = RelaySchedule(
          daily: DailySchedule(enabled: false, onTime: '00:00', offTime: '00:00'),
          weekly: List.generate(7, (i) => WeeklySchedule.empty()),
        );
        Get.back();
        _saveSchedule();
      },
    );
  }

  // Save schedule
  Future<void> saveSchedule() async {
    await _saveSchedule();
  }

  Future<void> _saveSchedule() async {
    // Update local storage
    try {
      print('Saving schedule: ${schedule.value}');
      var homeController = Get.find<HomeController>();
   
   // final devices = _storage.getDevices();
    final deviceIndex = homeController.devices.indexWhere((d) => d.id == device.id);
    print('Device index: $deviceIndex');
    if (deviceIndex != -1) {
      final relays = List<Relay>.from(homeController.devices[deviceIndex].relays);
      final relayIndex = relays.indexWhere((r) => r.relayId == relay.relayId);
      print('Relay index: $relayIndex');
      if (relayIndex != -1) {
        relays[relayIndex] = relay.copyWith(schedule: schedule.value);
        print('Updated relay schedule: ${relays[relayIndex].schedule}');
        final updatedDevice = homeController.devices[deviceIndex].copyWith(
          systemStatus: homeController.devices[deviceIndex].systemStatus?.copyWith(
            relays: relays,
          ),
        );
        print('Updated device: $updatedDevice');
        
        homeController.devices[deviceIndex] = updatedDevice;
        print('HomeController devices updated');
        // await _storage.saveDevices(devices);
      }
      print('Devices saved to storage');
    }
print('Attempting to save schedule to server...');
    // Send to server
    // Uncomment when API is ready
    /*
    final success = await _api.updateRelaySchedule(
      deviceId: device.id,
      relayId: relay.relayId,
      schedule: schedule.value,
    );

    if (!success) {
      Get.snackbar(
        'Error',
        'Failed to save schedule to server',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    */
   Get.back();


     Get.snackbar(
      'Success',
      'Schedule saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );

      
    } catch (e) {
      print('Error saving schedule: $e');
    }
    
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> pickTime(BuildContext context, Function(TimeOfDay) onTimePicked) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardTheme.color,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimePicked(picked);
    }
  }

  TimeOfDay get dailyOnTime => _parseTime(schedule.value.daily.onTime);
  TimeOfDay get dailyOffTime => _parseTime(schedule.value.daily.offTime);
  
  TimeOfDay getWeeklyOnTime(int dayIndex) => _parseTime(schedule.value.weekly[dayIndex].onTime);
  TimeOfDay getWeeklyOffTime(int dayIndex) => _parseTime(schedule.value.weekly[dayIndex].offTime);
}