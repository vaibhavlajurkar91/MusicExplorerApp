import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../controllers/artist_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../widgets/album_card.dart';
import '../widgets/shimmer_song_card.dart';
import '../widgets/song_card.dart';
import '../widgets/state_message.dart';
import 'album_screen.dart';
import 'song_detail_screen.dart';

class ArtistScreen extends StatefulWidget {
  final int artistId;
  final String artistName;

  /// Artwork of the song or album the user arrived from — the lookup endpoint
  /// does not return artist images.
  final String? artworkUrl;

  const ArtistScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    this.artworkUrl,
  });

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  late final String _tag;
  late final ArtistController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'artist_${widget.artistId}';
    _controller = Get.put(
      ArtistController(repository: Get.find(), artistId: widget.artistId),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ArtistController>(tag: _tag);
    super.dispose();
  }

  void _openSong(Song song) {
    Get.find<RecentlyPlayedController>().addSong(song);
    Get.to(() => SongDetailScreen(song: song));
  }

  void _openAlbum(Album album) {
    Get.to(() => AlbumScreen(album: album));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.artistName)),
      body: Obx(() {
        if (_controller.isLoading) {
          return ListView(
            children: const [
              SizedBox(height: 8),
              ShimmerSongCard(),
              ShimmerSongCard(),
              ShimmerSongCard(),
              ShimmerSongCard(),
            ],
          );
        }

        if (_controller.error.isNotEmpty) {
          return StateMessage(
            icon: Icons.error_outline,
            message: 'Could not load this artist',
            onRetry: _controller.load,
          );
        }

        if (_controller.isEmpty) {
          return const StateMessage(
            icon: Icons.person_off_outlined,
            message: 'Nothing found for this artist',
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ArtistHeader(
              name: widget.artistName,
              artworkUrl: widget.artworkUrl,
              albumCount: _controller.albums.length,
              songCount: _controller.topSongs.length,
            ),
            if (_controller.albums.isNotEmpty) ...[
              const _SectionTitle('Albums'),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _controller.albums.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final album = _controller.albums[index];
                    return AlbumCard(
                      album: album,
                      onTap: () => _openAlbum(album),
                    );
                  },
                ),
              ),
            ],
            if (_controller.topSongs.isNotEmpty) ...[
              const _SectionTitle('Top Songs'),
              ..._controller.topSongs.map(
                (song) => SongCard(song: song, onTap: () => _openSong(song)),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _ArtistHeader extends StatelessWidget {
  final String name;
  final String? artworkUrl;
  final int albumCount;
  final int songCount;

  const _ArtistHeader({
    required this.name,
    required this.artworkUrl,
    required this.albumCount,
    required this.songCount,
  });

  @override
  Widget build(BuildContext context) {
    final summary = [
      if (albumCount > 0) '$albumCount album${albumCount == 1 ? '' : 's'}',
      if (songCount > 0) '$songCount song${songCount == 1 ? '' : 's'}',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          ClipOval(
            child: artworkUrl != null && artworkUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: artworkUrl!.replaceAll('100x100', '300x300'),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const _ArtistAvatarFallback(),
                    placeholder: (context, url) => const _ArtistAvatarFallback(),
                  )
                : const _ArtistAvatarFallback(),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              summary,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtistAvatarFallback extends StatelessWidget {
  const _ArtistAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 56, color: Colors.white),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
