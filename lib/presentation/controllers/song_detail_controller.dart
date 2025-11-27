import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import 'favorites_controller.dart';

class SongDetailController extends GetxController {
  final SongRepository repository;
  final Song song;

  SongDetailController({
    required this.repository,
    required this.song,
  });

  late final AudioPlayer _audioPlayer;

  final _isFavorite = false.obs;
  final _isPlaying = false.obs;
  final _duration = Duration.zero.obs;
  final _position = Duration.zero.obs;

  bool get isFavorite => _isFavorite.value;
  bool get isPlaying => _isPlaying.value;
  Duration get duration => _duration.value;
  Duration get position => _position.value;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _checkFavoriteStatus();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((d) {
      _duration.value = d;
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _position.value = p;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying.value = false;
      _position.value = Duration.zero;
    });
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
          final favController = Get.find<FavoritesController>();
          favController.loadFavorites();
        } catch (e) {
          // FavoritesController not found, ignore
        }

        Get.snackbar(
          'Removed',
          'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await repository.addToFavorites(song);
        _isFavorite.value = true;

        try {
          final favController = Get.find<FavoritesController>();
          favController.loadFavorites();
        } catch (e) {
          // FavoritesController not found, ignore
        }

        Get.snackbar(
          'Added',
          'Added to favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> playPausePreview() async {
    if (song.previewUrl == null || song.previewUrl!.isEmpty) {
      Get.snackbar(
        'No Preview',
        'Preview not available for this song',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_isPlaying.value) {
        await _audioPlayer.pause();
        _isPlaying.value = false;
      } else {
        await _audioPlayer.play(UrlSource(song.previewUrl!));
        _isPlaying.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play preview',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}