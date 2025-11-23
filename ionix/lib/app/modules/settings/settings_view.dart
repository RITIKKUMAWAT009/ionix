import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../data/services/theme_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy load controller if not already loaded
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          _buildThemeCard(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Preferences'),
          _buildSettingsCard(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Data'),
          _buildDataCard(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'About'),
          _buildAboutCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Card(
      child: Column(
        children: [
          Obx(() => SwitchListTile(
            secondary: Icon(
              themeService.isDarkMode 
                  ? Icons.dark_mode_rounded 
                  : Icons.light_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeService.isDarkMode ? 'Enabled' : 'Disabled',
            ),
            value: themeService.isDarkMode,
            onChanged: (value) => controller.toggleTheme(),
          )),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Obx(() => SwitchListTile(
            secondary: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Receive device alerts'),
            value: controller.notificationsEnabled.value,
            onChanged: controller.toggleNotifications,
          )),
          Divider(height: 1, indent: 72),
          Obx(() => SwitchListTile(
            secondary: Icon(
              Icons.cloud_upload_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Auto Backup'),
            subtitle: const Text('Automatic cloud backup'),
            value: controller.autoBackup.value,
            onChanged: controller.toggleAutoBackup,
          )),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            onTap: controller.clearCache,
          ),
          Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(
              Icons.backup_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Backup Now'),
            subtitle: const Text('Manual backup'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            onTap: () {
              Get.snackbar(
                'Backup',
                'Backup started...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(
              Icons.policy_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Privacy Policy'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            onTap: () {},
          ),
          Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Terms of Service'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}