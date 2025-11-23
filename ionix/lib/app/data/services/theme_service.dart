import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class ThemeService extends GetxController {
  final _storage = Get.find<StorageService>();
  
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _storage.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _storage.setDarkMode(themeMode.value == ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    _storage.setDarkMode(mode == ThemeMode.dark);
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
}