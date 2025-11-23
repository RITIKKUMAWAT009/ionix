import 'package:get/get.dart';
import '../../data/services/storage_service.dart';

class ProfileController extends GetxController {
  final _storage = Get.find<StorageService>();
  
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    userName.value = _storage.userName;
    userEmail.value = _storage.userEmail;
  }

  void updateProfile(String name, String email) {
    _storage.setUserName(name);
    _storage.setUserEmail(email);
    loadProfile();
    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'Logged Out',
          'You have been logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}