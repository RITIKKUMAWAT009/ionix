import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/models/device_model.dart';
import '../profile/profile_view.dart';
import '../settings/settings_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.selectedBottomIndex.value,
        children: const [
          _HomeContent(),
        //  Center(child: Text('Scenes', style: TextStyle(fontSize: 20))),
        //  Center(child: Text('Insights', style: TextStyle(fontSize: 20))),
        //  Center(child: Text('Messages', style: TextStyle(fontSize: 20))),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    ));
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0),
            //   _buildNavItem(context, Icons.lightbulb_outline_rounded, 'Scene', 1),
            //   _buildNavItem(context, Icons.insights_rounded, 'Insight', 2),
            //  _buildNavItem(context, Icons.chat_bubble_outline_rounded, 'Message', 3),
              _buildNavItem(context, Icons.person_outline_rounded, 'Profile', 1),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = controller.selectedBottomIndex.value == index;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return InkWell(
      onTap: () => controller.selectBottomTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends GetView<HomeController> {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Ionix', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            //Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshDevices,
          ),
          const IconButton(
            icon: Icon(Icons.add_circle, size: 28),
            onPressed: null
            //todo : controller.addDevice,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context),
          _buildStatsBar(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.devices.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final devices = controller.filteredDevices;
              
              if (devices.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshDevices,
                  child: ListView(
                    children:[ Center(
                      heightFactor: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No devices found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a device to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
         ] ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshDevices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return _DeviceCard(device: devices[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.rooms.length,
              itemBuilder: (context, index) {
                final room = controller.rooms[index];
                final isSelected = controller.selectedTabIndex.value == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(room.name),
                    selected: isSelected,
                    onSelected: (selected) => controller.selectTab(index),
                    backgroundColor: Colors.transparent,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.transparent,
                    ),
                  ),
                );
              },
            )),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Get.to(() => const SettingsView()),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.devices_rounded,
            '${controller.onlineDevices}/${controller.totalDevices}',
            'Devices',
          ),
          Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
          _buildStatItem(
            context,
            Icons.power_rounded,
            '${controller.activeRelays}/${controller.totalRelays}',
            'Relays',
          ),
          Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
          _buildStatItem(
            context,
            Icons.schedule_rounded,
            '${controller.scheduleCount}',
            'Scheduled',
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _DeviceCard extends GetView<HomeController> {
  final Device device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceHeader(context),
            if (device.systemStatus != null) ...[
              const SizedBox(height: 8),
              _buildDeviceInfo(context),
            ],
            const SizedBox(height: 16),
            _buildRelayControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: device.isOnline
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.developer_board_rounded,
            color: device.isOnline
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
               Text(
                device.id,
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                device.ipAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildOnlineIndicator(context),
        //Delete button
        IconButton(
          icon: Icon(Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error),  
          onPressed:(){
            controller.deleteDevice(device.id);
          },
        ),
      ],
    );
  }

  Widget _buildOnlineIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: device.isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: device.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            device.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: device.isOnline ? Colors.green : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    final status = device.systemStatus!;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _buildInfoChip(context, Icons.schedule, status.uptimeFormatted),
        _buildInfoChip(context, Icons.wifi, '${status.wifiRssi} dBm'),
        _buildInfoChip(
          context,
          Icons.power_settings_new,
          '${device.activeRelayCount}/${device.relayCount} ON',
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelayControls(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: device.relays.take(10).map((relay) {
        return _RelayButton(device: device, relay: relay);
      }).toList(),
    );
  }
}

// class _RelayButton extends GetView<HomeController> {
//   final Device device;
//   final Relay relay;

//   const _RelayButton({
//     required this.device,
//     required this.relay,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // Find current state
//       final currentDevice = controller.devices.firstWhereOrNull((d) => d.id == device.id);
//       final currentRelay = currentDevice?.relays.firstWhereOrNull((r) => r.relayId == relay.relayId);
//       final isEnabled = currentRelay?.state ?? false;

//       return InkWell(
//         onTap: () => controller.toggleRelay(device.id, relay.relayId),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: (Get.width - 64) / 6,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isEnabled
//                 ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
//                 : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isEnabled
//                   ? Theme.of(context).colorScheme.primary
//                   : Colors.transparent,
//               width: 1.5,
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: isEnabled
//                       ? Theme.of(context).colorScheme.primary
//                       : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 20,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Text(
//                   relay.name,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 10,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               if (relay.hasActiveSchedule) ...[
//                 const SizedBox(height: 4),
//                 Icon(
//                   Icons.schedule,
//                   size: 12,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }


class _RelayButton extends GetView<HomeController> {
  final Device device;
  final Relay relay;

  const _RelayButton({
    required this.device,
    required this.relay,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Find current state
      final currentDevice = controller.devices.firstWhereOrNull((d) => d.id == device.id);
      final currentRelay = currentDevice?.relays.firstWhereOrNull((r) => r.relayId == relay.relayId);
      final isEnabled = currentRelay?.state ?? false;

      return InkWell(
        onTap: () => controller.toggleRelay(device.id, relay.relayId),
        onLongPress: () {
          // Navigate to schedule screen
          Get.toNamed(
            '/schedule',
            arguments: {
              'device': device,
              'relay': relay,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: (Get.width - 64) / 6,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isEnabled
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
     :Colors.red.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      :Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  relay.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (relay.hasActiveSchedule) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}