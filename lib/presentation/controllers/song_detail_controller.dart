import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import 'favorites_controller.dart';

class SongDetailController extends GetxController {
  final SongRepository repository;
  final Song song;

  SongDetailController({required this.repository, required this.song});

  final _isFavorite = false.obs;
  bool get isFavorite => _isFavorite.value;

  @override
  void onInit() {
    super.onInit();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    _isFavorite.value = await repository.isFavorite(song.trackId);
  }

  Future<void> toggleFavorite() async {
    try {
      if (_isFavorite.value) {
        await repository.removeFromFavorites(song.trackId);
        _isFavorite.value = false;
        try {
          Get.find<FavoritesController>().loadFavorites();
        } catch (_) {}
        Get.snackbar('Removed', 'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await repository.addToFavorites(song);
        _isFavorite.value = true;
        try {
          Get.find<FavoritesController>().loadFavorites();
        } catch (_) {}
        Get.snackbar('Added', 'Added to favorites',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
