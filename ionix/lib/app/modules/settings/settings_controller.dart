import 'package:get/get.dart';
import '../../data/services/theme_service.dart';

class SettingsController extends GetxController {
  final _themeService = Get.find<ThemeService>();

  final RxBool notificationsEnabled = true.obs;
  final RxBool autoBackup = true.obs;

  bool get isDarkMode => _themeService.isDarkMode;

  void toggleTheme() {
    _themeService.toggleTheme();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    Get.snackbar(
      'Notifications',
      value ? 'Notifications enabled' : 'Notifications disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleAutoBackup(bool value) {
    autoBackup.value = value;
    Get.snackbar(
      'Auto Backup',
      value ? 'Auto backup enabled' : 'Auto backup disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearCache() {
    Get.defaultDialog(
      title: 'Clear Cache',
      middleText: 'Are you sure you want to clear cache?',
      textCancel: 'Cancel',
      textConfirm: 'Clear',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'Success',
          'Cache cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}