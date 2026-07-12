import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/shimmer_song_card.dart';
import '../widgets/song_card.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<HomeController>().loadMoreSongs();
    }
  }

  void _openSong(song) {
    Get.find<RecentlyPlayedController>().addSong(song);
    Get.to(() => SongDetailScreen(song: song));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Get.find<HomeController>().searchSongs(query: 'pop');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Get.find<HomeController>().searchSongs(query: value);
                }
              },
            ),
          ),
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
                      return SongCard(
                        song: song,
                        onTap: () => _openSong(song),
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
