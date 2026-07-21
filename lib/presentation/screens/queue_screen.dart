import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          TextButton(
            onPressed: () async {
              await player.clearQueue();
              Get.back();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
      // Outer Obx only reads player.queue for the empty check — does not read
      // position/duration so it won't rebuild every 200 ms from the seek bar.
      body: Obx(() {
        if (player.queue.isEmpty) {
          return const Center(child: Text('Queue is empty'));
        }
        return const Column(
          children: [
            _NowPlayingSection(),
            Divider(height: 1),
            Expanded(child: _QueueList()),
          ],
        );
      }),
    );
  }
}

// Reads position/duration/isPlaying — rebuilds frequently with the seek bar.
class _NowPlayingSection extends StatelessWidget {
  const _NowPlayingSection();

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Obx(() {
      final song = player.currentSong!;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: song.artworkUrl100,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.trackName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artistName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Builder(builder: (context) {
                      // During a track transition duration resets before the
                      // new position arrives, so clamp to keep value <= max.
                      final max = player.duration.value.inSeconds > 0
                          ? player.duration.value.inSeconds.toDouble()
                          : 1.0;
                      return Slider(
                        value: player.position.value.inSeconds
                            .toDouble()
                            .clamp(0.0, max),
                        max: max,
                        onChanged: (v) =>
                            player.seekTo(Duration(seconds: v.toInt())),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(_fmt(player.position.value),
                            style: const TextStyle(fontSize: 11)),
                        const Spacer(),
                        Text(_fmt(player.duration.value),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: player.hasPrev ? player.previous : null,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    player.isPlaying.value
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: player.playPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: player.hasNext ? player.next : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// Reads queue and currentIndex only — insulated from 200 ms position updates
// so ReorderableListView drag state is never interrupted.
class _QueueList extends StatelessWidget {
  const _QueueList();

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'UP NEXT  ·  ${player.queue.length} songs',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: player.queue.length,
              onReorder: player.reorderQueue,
              itemBuilder: (context, index) {
                final item = player.queue[index];
                final isCurrent = index == player.currentIndex.value;
                return ListTile(
                  key: ValueKey('${item.trackId}_$index'),
                  selected: isCurrent,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: item.artworkUrl100,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 18),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 18),
                      ),
                    ),
                  ),
                  title: Text(
                    item.trackName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    item.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isCurrent
                      ? Icon(Icons.volume_up,
                          color: Theme.of(context).primaryColor, size: 18)
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => player.removeFromQueue(index),
                        ),
                  onTap: () => player.jumpTo(index),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
