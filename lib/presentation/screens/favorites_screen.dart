import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../widgets/shimmer_song_card.dart';
import '../widgets/song_card.dart';
import 'song_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: GetX<FavoritesController>(
        builder: (controller) {
          if (controller.isLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerSongCard(),
            );
          }

          if (controller.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add songs to your favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshFavorites(),
            child: ListView.builder(
              itemCount: controller.favorites.length,
              itemBuilder: (context, index) {
                final song = controller.favorites[index];
                return Dismissible(
                  key: Key(song.trackId.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    controller.removeFromFavorites(song);
                  },
                  child: SongCard(
                    song: song,
                    onTap: () {
                      Get.find<RecentlyPlayedController>().addSong(song);
                      Get.find<PlayerController>()
                          .playQueue(controller.favorites.toList(), index);
                      Get.to(() => SongDetailScreen(song: song));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}