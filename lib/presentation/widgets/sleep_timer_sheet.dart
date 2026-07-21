import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';

class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SleepTimerSheet(),
    );
  }

  static const _presets = [
    (label: '5 min', duration: Duration(minutes: 5)),
    (label: '15 min', duration: Duration(minutes: 15)),
    (label: '30 min', duration: Duration(minutes: 30)),
    (label: '60 min', duration: Duration(minutes: 60)),
  ];

  String _formatRemaining(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.bedtime_outlined),
              const SizedBox(width: 8),
              Text(
                'Sleep Timer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (player.hasSleepTimer) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stopping in',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatRemaining(player.sleepTimerRemaining!),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        player.cancelSleepTimer();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 16),
          Text(
            'Set timer',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presets.map((preset) {
              return Obx(() {
                final isActive = player.hasSleepTimer &&
                    player.sleepTimerRemaining!.inMinutes ==
                        preset.duration.inMinutes;
                return ChoiceChip(
                  label: Text(preset.label),
                  selected: isActive,
                  onSelected: (_) {
                    player.setSleepTimer(preset.duration);
                    Navigator.pop(context);
                    Get.snackbar(
                      'Sleep Timer',
                      'Stopping in ${preset.label}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }
}
