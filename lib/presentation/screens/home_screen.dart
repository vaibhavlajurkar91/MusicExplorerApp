import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/player_controller.dart';
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
      final controller = Get.find<HomeController>();
      controller.loadMoreSongs();
    }
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
                themeController.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
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
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Get.find<HomeController>().searchSongs(query: value);
                }
              },
            ),
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
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
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
                  return const Center(
                    child: Text('No songs found'),
                  );
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
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final song = controller.songs[index];
                      final player = Get.find<PlayerController>();
                      return SongCard(
                        song: song,
                        onTap: () {
                          player.playQueue(
                              controller.songs.toList(), index);
                          Get.to(() => SongDetailScreen(song: song));
                        },
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