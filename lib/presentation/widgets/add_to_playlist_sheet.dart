import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../controllers/playlist_controller.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  static void show(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaylistController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add to Playlist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                    onPressed: () => _showCreateDialog(context, controller),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.playlists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.queue_music,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No playlists yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _showCreateDialog(context, controller),
                          child: const Text('Create a playlist'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: controller.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = controller.playlists[index];
                    final alreadyAdded =
                        playlist.songs.any((s) => s.trackId == song.trackId);
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.queue_music,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                      title: Text(playlist.name),
                      subtitle: Text(
                          '${playlist.songs.length} song${playlist.songs.length == 1 ? '' : 's'}'),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: alreadyAdded
                          ? null
                          : () {
                              controller.addSongToPlaylist(playlist, song);
                              Navigator.pop(context);
                            },
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(
      BuildContext context, PlaylistController controller) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _create(
              dialogContext, context, controller, nameController.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _create(
                dialogContext, context, controller, nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _create(
    BuildContext dialogContext,
    BuildContext sheetContext,
    PlaylistController controller,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await controller.createPlaylist(trimmed);
    if (dialogContext.mounted) Navigator.pop(dialogContext);
    // Add song to the newly created playlist
    final newPlaylist = controller.playlists.last;
    await controller.addSongToPlaylist(newPlaylist, song);
    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }
}
