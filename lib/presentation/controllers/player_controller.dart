import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';

class PlayerController extends GetxController {
  late final AudioPlayer _audioPlayer;

  final _currentSong = Rxn<Song>();
  final _isPlaying = false.obs;
  final _duration = Duration.zero.obs;
  final _position = Duration.zero.obs;

  Song? get currentSong => _currentSong.value;
  bool get isPlaying => _isPlaying.value;
  Duration get duration => _duration.value;
  Duration get position => _position.value;
  bool get hasActiveSong => _currentSong.value != null;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) => _duration.value = d);
    _audioPlayer.onPositionChanged.listen((p) => _position.value = p);
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying.value = false;
      _position.value = Duration.zero;
    });
  }

  Future<void> playSong(Song song) async {
    if (song.previewUrl == null || song.previewUrl!.isEmpty) {
      Get.snackbar(
        'No Preview',
        'Preview not available for this song',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_currentSong.value?.trackId == song.trackId) {
      await togglePlayPause();
      return;
    }
    _currentSong.value = song;
    _position.value = Duration.zero;
    _duration.value = Duration.zero;
    _isPlaying.value = false;
    try {
      await _audioPlayer.play(UrlSource(song.previewUrl!));
      _isPlaying.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play preview',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying.value) {
        await _audioPlayer.pause();
        _isPlaying.value = false;
      } else {
        await _audioPlayer.resume();
        _isPlaying.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Playback error', snackPosition: SnackPosition.BOTTOM);
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
