import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../controllers/player_controller.dart';
import '../controllers/song_detail_controller.dart';
import '../widgets/sleep_timer_sheet.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final detail = Get.put(
      SongDetailController(repository: Get.find(), song: song),
    );
    final player = Get.find<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Details'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                player.hasSleepTimer ? Icons.bedtime : Icons.bedtime_outlined,
                color: player.hasSleepTimer
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: 'Sleep timer',
              onPressed: () => SleepTimerSheet.show(context),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'add_queue') {
                player.addToQueue(song);
                Get.snackbar('Queue', 'Added to queue',
                    snackPosition: SnackPosition.BOTTOM);
              } else if (value == 'play_next') {
                player.addNext(song);
                Get.snackbar('Queue', 'Will play next',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'add_queue',
                child: Row(children: [
                  Icon(Icons.queue_music),
                  SizedBox(width: 8),
                  Text('Add to Queue'),
                ]),
              ),
              PopupMenuItem(
                value: 'play_next',
                child: Row(children: [
                  Icon(Icons.playlist_add),
                  SizedBox(width: 8),
                  Text('Play Next'),
                ]),
              ),
            ],
          ),
          Obx(() => IconButton(
                icon: Icon(
                  detail.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: detail.isFavorite ? Colors.red : null,
                ),
                onPressed: detail.toggleFavorite,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Hero(
              tag: 'song_${song.trackId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: song.artworkUrl100.replaceAll('100x100', '400x400'),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    song.trackName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artistName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.collectionName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  if (song.primaryGenreName != null) ...[
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(song.primaryGenreName!),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (song.previewUrl != null && !player.playbackSupported) ...[
              // No just_audio backend on Windows/Linux: show why instead of a
              // play button that would silently do nothing.
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  PlayerController.unsupportedPlatformMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ] else if (song.previewUrl != null) ...[
              Obx(() {
                final isCurrent =
                    player.currentSong?.trackId == song.trackId;

                if (isCurrent) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(_fmt(player.position.value)),
                            Expanded(
                              child: Builder(builder: (context) {
                                // Duration resets before the new position
                                // during a track change; clamp so the Slider
                                // never sees value > max.
                                final max =
                                    player.duration.value.inSeconds > 0
                                        ? player.duration.value.inSeconds
                                            .toDouble()
                                        : 1.0;
                                return Slider(
                                  value: player.position.value.inSeconds
                                      .toDouble()
                                      .clamp(0.0, max),
                                  max: max,
                                  onChanged: (v) => player
                                      .seekTo(Duration(seconds: v.toInt())),
                                );
                              }),
                            ),
                            Text(_fmt(player.duration.value)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, size: 36),
                            onPressed: player.hasPrev ? player.previous : null,
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.large(
                            onPressed: player.playPause,
                            child: Icon(
                              player.isPlaying.value ? Icons.pause : Icons.play_arrow,
                              size: 48,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.skip_next, size: 36),
                            onPressed: player.hasNext ? player.next : null,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Song is not currently playing — show a simple play button.
                return Column(
                  children: [
                    FloatingActionButton.large(
                      onPressed: () => player.playQueue([song], 0),
                      child: const Icon(Icons.play_arrow, size: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to play preview',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Preview',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Preview not available',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
