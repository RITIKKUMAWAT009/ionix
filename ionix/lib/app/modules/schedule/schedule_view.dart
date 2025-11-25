import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule'),
            Text(
              controller.relay.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.deleteSchedule,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildDailySchedule(context);
              } else {
                return _buildWeeklySchedule(context);
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              'Daily',
              0,
              Icons.today_rounded,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              'Weekly',
              1,
              Icons.calendar_month_rounded,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, int index, IconData icon) {
    final isSelected = controller.selectedTab.value == index;
    
    return InkWell(
      onTap: () => controller.selectTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySchedule(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  secondary: Icon(
                    Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Enable Daily Schedule'),
                  subtitle: Text(
                    controller.schedule.value.daily.enabled
                        ? 'Schedule is active'
                        : 'Schedule is disabled',
                  ),
                  value: controller.schedule.value.daily.enabled,
                  onChanged: controller.toggleDailySchedule,
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (!controller.schedule.value.daily.enabled) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Daily schedule is disabled',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enable to set a daily on/off schedule',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildTimeCard(
                  context,
                  'Turn ON Time',
                  controller.dailyOnTime,
                  Icons.power_settings_new,
                  Colors.green,
                  (time) => controller.setDailyOnTime(time),
                ),
                const SizedBox(height: 12),
                _buildTimeCard(
                  context,
                  'Turn OFF Time',
                  controller.dailyOffTime,
                  Icons.power_off,
                  Colors.red,
                  (time) => controller.setDailyOffTime(time),
                ),
                const SizedBox(height: 24),
                _buildSchedulePreview(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(BuildContext context) {
    return Column(
      children: [
        _buildWeekdaySelector(context),
        Expanded(
          child: Obx(() {
            final dayIndex = controller.selectedWeekday.value;
            final daySchedule = controller.schedule.value.weekly[dayIndex];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: SwitchListTile(
                      secondary: Icon(
                        Icons.schedule_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text('Enable ${controller.weekdays[dayIndex]}'),
                      subtitle: Text(
                        daySchedule.enabled
                            ? 'Schedule is active'
                            : 'Schedule is disabled',
                      ),
                      value: daySchedule.enabled,
                      onChanged: (value) => controller.toggleWeeklySchedule(dayIndex, value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!daySchedule.enabled)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Schedule disabled for ${controller.weekdays[dayIndex]}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildTimeCard(
                          context,
                          'Turn ON Time',
                          controller.getWeeklyOnTime(dayIndex),
                          Icons.power_settings_new,
                          Colors.green,
                          (time) => controller.setWeeklyOnTime(dayIndex, time),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeCard(
                          context,
                          'Turn OFF Time',
                          controller.getWeeklyOffTime(dayIndex),
                          Icons.power_off,
                          Colors.red,
                          (time) => controller.setWeeklyOffTime(dayIndex, time),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

 Widget _buildWeekdaySelector(BuildContext context) {
  return Container(
    height: 80,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Obx(() => ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.weekdays.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => controller.selectWeekday(index),
            borderRadius: BorderRadius.circular(12),

            child: Obx(() {
              final isSelected = controller.selectedWeekday.value == index;
              final isEnabled = controller.schedule.value.weekly[index].enabled;

              return Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.weekdays[index].substring(0, 3),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isEnabled)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    )),
  );
}

  Widget _buildTimeCard(
    BuildContext context,
    String title,
    TimeOfDay time,
    IconData icon,
    Color color,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Card(
      child: InkWell(
        onTap: () => controller.pickTime(context, onTimeChanged),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time.format(context),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulePreview(BuildContext context) {
    return Obx(() {
      final daily = controller.schedule.value.daily;
      if (!daily.enabled) return const SizedBox.shrink();

      return Card(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Schedule Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPreviewRow(
                context,
                'Relay will turn ON at',
                daily.onTime,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildPreviewRow(
                context,
                'Relay will turn OFF at',
                daily.offTime,
                Colors.red,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This schedule will repeat every day',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPreviewRow(BuildContext context, String label, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed:() async {
                  await controller.saveSchedule();
                //  Get.back();
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Schedule'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}