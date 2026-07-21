import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../controllers/player_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/recently_played_controller.dart';
import 'song_detail_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  /// Plays the whole playlist starting at [index] so skip-next walks the rest
  /// of it, rather than queueing the tapped song on its own.
  void _openSong(List<Song> songs, int index) {
    final song = songs[index];
    Get.find<RecentlyPlayedController>().addSong(song);
    Get.find<PlayerController>().playQueue(songs.toList(), index);
    Get.to(() => SongDetailScreen(song: song));
  }

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

    return Obx(() {
      final current = playlistController.playlists
          .firstWhereOrNull((p) => p.id == playlist.id) ?? playlist;

      return Scaffold(
        appBar: AppBar(
          title: Text(current.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showRenameDialog(context, playlistController, current),
            ),
          ],
        ),
        body: current.songs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.queue_music, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No songs yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Long-press any song to add it here',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: current.songs.length,
                itemBuilder: (context, index) {
                  final song = current.songs[index];
                  return Dismissible(
                    key: Key('${current.id}_${song.trackId}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) =>
                        playlistController.removeSongFromPlaylist(current, song),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: song.artworkUrl100,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            color: Colors.grey[300],
                            child: const Icon(Icons.music_note),
                          ),
                        ),
                      ),
                      title: Text(
                        song.trackName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        song.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () => _openSong(current.songs, index),
                      ),
                      onTap: () => _openSong(current.songs, index),
                    ),
                  );
                },
              ),
      );
    });
  }

  void _showRenameDialog(
      BuildContext context, PlaylistController controller, Playlist current) {
    final nameController = TextEditingController(text: current.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                controller.renamePlaylist(current, name);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
