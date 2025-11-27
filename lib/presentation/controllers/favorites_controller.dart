import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class FavoritesController extends GetxController {
  final SongRepository repository;

  FavoritesController({required this.repository});

  final _favorites = <Song>[].obs;
  final _isLoading = false.obs;

  List<Song> get favorites => _favorites;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading.value = true;

    try {
      final results = await repository.getFavorites();
      _favorites.value = results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeFromFavorites(Song song) async {
    try {
      await repository.removeFromFavorites(song.trackId);
      _favorites.removeWhere((s) => s.trackId == song.trackId);
      Get.snackbar(
        'Removed',
        'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}