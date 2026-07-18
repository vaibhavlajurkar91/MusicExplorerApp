import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../screens/queue_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Obx(() {
      if (player.queue.isEmpty) return const SizedBox.shrink();

      final song = player.currentSong!;
      return GestureDetector(
        onTap: () => Get.to(() => const QueueScreen()),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: song.artworkUrl100,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 20),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.trackName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artistName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: player.hasPrev ? player.previous : null,
              ),
              IconButton(
                icon: Icon(player.isPlaying.value ? Icons.pause : Icons.play_arrow),
                onPressed: player.playPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: player.hasNext ? player.next : null,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      );
    });
  }
}
