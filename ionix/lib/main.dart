import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionix/app/data/services/websocket_service.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/theme_service.dart';
import 'app/data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services

  Get.put(WebSocketService(url: 'ws://16.171.209.89:3000/ws'));

  await Get.putAsync(() => StorageService().init());
  Get.put(ThemeService());
  // Get.put(ApiService()); // Uncomment when API is ready
  
  runApp(const IonixApp());
}

class IonixApp extends StatelessWidget {
  const IonixApp({super.key});

  @override

  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: 'Ionix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode.value,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ));
  }
}