import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/song.dart';
import '../controllers/player_controller.dart';
import '../controllers/song_detail_controller.dart';
import '../widgets/sleep_timer_sheet.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SongDetailController(repository: Get.find(), song: song),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              final buffer = StringBuffer(
                'Check out "${song.trackName}" by ${song.artistName}',
              );
              if (song.previewUrl != null) {
                buffer.write('\n${song.previewUrl}');
              }
              Share.share(buffer.toString(), subject: song.trackName);
            },
          ),
          Obx(() {
            final player = Get.find<PlayerController>();
            return IconButton(
              icon: Icon(
                player.hasSleepTimer ? Icons.bedtime : Icons.bedtime_outlined,
                color: player.hasSleepTimer
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: 'Sleep timer',
              onPressed: () => SleepTimerSheet.show(context),
            );
          }),
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: controller.isFavorite ? Colors.red : null,
              ),
              onPressed: () => controller.toggleFavorite(),
            ),
          ),
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
                  placeholder: (context, url) => Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                          Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (song.previewUrl != null) ...[
              Obx(() {
                final player = controller.player;
                final isThisSong =
                    player.currentSong?.trackId == song.trackId;
                final isPlaying = isThisSong && player.isPlaying;
                final position =
                    isThisSong ? player.position : Duration.zero;
                final duration =
                    isThisSong ? player.duration : Duration.zero;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Text(_formatDuration(position)),
                          Expanded(
                            child: Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble() > 0
                                  ? duration.inSeconds.toDouble()
                                  : 1,
                              onChanged: (value) {
                                controller
                                    .seekTo(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton.large(
                      onPressed: () => player.togglePlayPause(),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 48,
                      ),
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
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Preview not available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
