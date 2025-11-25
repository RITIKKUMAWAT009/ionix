import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionix/app/modules/home/home_controller.dart';
import 'profile_controller.dart';
import '../../data/services/theme_service.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy load controller if not already loaded
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildProfileStats(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Center(
            child: Obx(() => Text(
              controller.userName.value.isNotEmpty 
                  ? controller.userName.value[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Text(
          controller.userName.value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )),
        const SizedBox(height: 4),
        Obx(() => Text(
          controller.userEmail.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        )),
      ],
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(context, Get.find<HomeController>().totalDevices.toString(), 'Devices'),
        _buildStatCard(context, Get.find<HomeController>().totalRelays.toString(), 'Relays'),
        _buildStatCard(context, Get.find<HomeController>().scheduleCount.toString(), 'Schedules'),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          Icons.notifications_outlined,
          'Notifications',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.security_outlined,
          'Security',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.help_outline,
          'Help & Support',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.info_outline,
          'About',
          () {},
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          context,
          Icons.logout,
          'Logout',
          controller.logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive 
              ? Colors.red 
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? Colors.red 
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: controller.userName.value);
    final emailController = TextEditingController(text: controller.userEmail.value);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
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
              controller.updateProfile(
                nameController.text,
                emailController.text,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}