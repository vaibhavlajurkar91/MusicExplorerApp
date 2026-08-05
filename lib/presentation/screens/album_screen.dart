import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../controllers/album_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../widgets/state_message.dart';
import 'artist_screen.dart';
import 'song_detail_screen.dart';

class AlbumScreen extends StatefulWidget {
  final Album album;

  const AlbumScreen({super.key, required this.album});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final String _tag;
  late final AlbumController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'album_${widget.album.collectionId}';
    _controller = Get.put(
      AlbumController(
        repository: Get.find(),
        collectionId: widget.album.collectionId,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<AlbumController>(tag: _tag);
    super.dispose();
  }

  void _openSong(Song song) {
    Get.find<RecentlyPlayedController>().addSong(song);
    Get.to(() => SongDetailScreen(song: song));
  }

  void _openArtist() {
    final artistId = widget.album.artistId;
    if (artistId == null) return;
    Get.to(
      () => ArtistScreen(
        artistId: artistId,
        artistName: widget.album.artistName,
        artworkUrl: widget.album.artworkUrl100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: Obx(() {
        if (_controller.error.isNotEmpty) {
          return StateMessage(
            icon: Icons.error_outline,
            message: 'Could not load this album',
            onRetry: _controller.load,
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _AlbumHeader(
              album: widget.album,
              trackCount: _controller.tracks.length,
              onArtistTap: widget.album.artistId != null ? _openArtist : null,
            ),
            const Divider(height: 32),
            if (_controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_controller.tracks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: StateMessage(
                  icon: Icons.music_off,
                  message: 'No tracks found for this album',
                ),
              )
            else
              ..._controller.tracks.map(
                (track) => _TrackTile(
                  song: track,
                  onTap: () => _openSong(track),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _AlbumHeader extends StatelessWidget {
  final Album album;
  final int trackCount;
  final VoidCallback? onArtistTap;

  const _AlbumHeader({
    required this.album,
    required this.trackCount,
    required this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (album.releaseDate != null) '${album.releaseDate!.year}',
      if (trackCount > 0) '$trackCount track${trackCount == 1 ? '' : 's'}',
      if (album.primaryGenreName != null) album.primaryGenreName!,
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: album.artworkUrl100.replaceAll('100x100', '400x400'),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.album, size: 80),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            album.collectionName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onArtistTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      album.artistName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: onArtistTap != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (onArtistTap != null) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _TrackTile({required this.song, required this.onTap});

  String _formatDuration(int? millis) {
    if (millis == null) return '--:--';
    final duration = Duration(milliseconds: millis);
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Obx(() {
      final player = Get.find<PlayerController>();
      final isCurrent = player.currentSong?.trackId == song.trackId;

      return ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 32,
          child: Center(
            child: isCurrent
                ? Icon(Icons.volume_up, size: 20, color: primary)
                : Text(
                    '${song.trackNumber ?? '-'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
          ),
        ),
        title: Text(
          song.trackName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? primary : null,
          ),
        ),
        subtitle: song.previewUrl == null
            ? Text(
                'No preview',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(song.trackTimeMillis),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Obx(() {
              final favController = Get.find<FavoritesController>();
              final isFav = favController.isFavorite(song.trackId);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => favController.toggleFavorite(song),
              );
            }),
          ],
        ),
      );
    });
  }
}
