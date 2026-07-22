import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../controllers/home_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../widgets/shimmer_song_card.dart';
import '../widgets/song_card.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _genres = [
  ('Pop', 'pop'),
  ('Rock', 'rock'),
  ('Hip-Hop', 'hip-hop'),
  ('Jazz', 'jazz'),
  ('Electronic', 'electronic'),
  ('Classical', 'classical'),
  ('R&B', 'r&b'),
  ('Country', 'country'),
];

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<HomeController>().loadMoreSongs();
    }
  }

  /// Records the song in Recently Played, hands the surrounding list to the
  /// player as the new queue, then opens the detail view. Callers with no
  /// surrounding list (the Recently Played strip) get a single-song queue.
  void _openSong(Song song, {List<Song>? queue, int index = 0}) {
    Get.find<RecentlyPlayedController>().addSong(song);
    Get.find<PlayerController>()
        .playQueue(queue ?? [song], queue == null ? 0 : index);
    Get.to(() => SongDetailScreen(song: song));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Explorer'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Get.find<HomeController>().selectGenre('pop');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                Get.find<HomeController>().clearGenreSelection();
                setState(() {});
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchFocusNode.unfocus();
                  Get.find<HomeController>().searchSongs(query: value);
                }
              },
            ),
          ),
          // Search history panel (visible when field is focused and empty)
          if (_isSearchFocused && _searchController.text.isEmpty)
            Obx(() {
              final homeController = Get.find<HomeController>();
              if (homeController.searchHistory.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent searches',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: homeController.clearHistory,
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: homeController.searchHistory.length,
                    itemBuilder: (context, index) {
                      final query = homeController.searchHistory[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 20),
                        title: Text(query),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              homeController.removeFromHistory(query),
                        ),
                        onTap: () {
                          _searchController.text = query;
                          _searchFocusNode.unfocus();
                          homeController.searchSongs(query: query);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
          // Genre filter chips
          Obx(() {
            final homeController = Get.find<HomeController>();
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final (label, value) = _genres[index];
                  final selected =
                      homeController.selectedGenre == value;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) {
                      _searchController.clear();
                      homeController.selectGenre(value);
                      setState(() {});
                    },
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          // Recently Played section
          GetX<RecentlyPlayedController>(
            builder: (recentController) {
              if (recentController.songs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Recently Played',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: recentController.songs.length,
                      itemBuilder: (context, index) {
                        final song = recentController.songs[index];
                        return GestureDetector(
                          onTap: () => _openSong(song),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: song.artworkUrl100,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 72,
                                      height: 72,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.music_note),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.trackName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
          Expanded(
            child: GetX<HomeController>(
              builder: (controller) {
                if (controller.isLoading && controller.songs.isEmpty) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) => const ShimmerSongCard(),
                  );
                }

                if (controller.error.isNotEmpty && controller.songs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading songs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => controller.searchSongs(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.songs.isEmpty) {
                  return const Center(child: Text('No songs found'));
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshSongs(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.songs.length +
                        (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.songs.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final song = controller.songs[index];
                      final player = Get.find<PlayerController>();
                      return SongCard(
                        song: song,
                        onTap: () => _openSong(
                          song,
                          queue: controller.songs.toList(),
                          index: index,
                        ),
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading:
                                        const Icon(Icons.queue_music),
                                    title:
                                        const Text('Add to Queue'),
                                    onTap: () {
                                      player.addToQueue(song);
                                      Get.back();
                                      Get.snackbar(
                                        'Queue',
                                        'Added to queue',
                                        snackPosition:
                                            SnackPosition.BOTTOM,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading:
                                        const Icon(Icons.playlist_add),
                                    title: const Text('Play Next'),
                                    onTap: () {
                                      player.addNext(song);
                                      Get.back();
                                      Get.snackbar(
                                        'Queue',
                                        'Will play next',
                                        snackPosition:
                                            SnackPosition.BOTTOM,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                        Icons.playlist_add_check),
                                    title:
                                        const Text('Add to Playlist'),
                                    onTap: () {
                                      Get.back();
                                      AddToPlaylistSheet.show(
                                          context, song);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
