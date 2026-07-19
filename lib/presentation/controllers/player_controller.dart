import 'package:get/get.dart';
import '../../core/audio/music_audio_handler.dart';
import '../../domain/entities/song.dart';

class PlayerController extends GetxController {
  late final MusicAudioHandler _handler;

  final queue = <Song>[].obs;
  final currentIndex = 0.obs;
  final isPlaying = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  Song? get currentSong =>
      queue.isNotEmpty ? queue[currentIndex.value] : null;
  bool get hasNext => currentIndex.value < queue.length - 1;
  bool get hasPrev => currentIndex.value > 0;

  @override
  void onInit() {
    super.onInit();
    _handler = Get.find<MusicAudioHandler>();

    _handler.songsStream.listen((songs) => queue.assignAll(songs));
    _handler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      currentIndex.value = state.queueIndex ?? 0;
    });
    _handler.mediaItem.listen((_) {
      position.value = Duration.zero;
      duration.value = Duration.zero;
    });
    _handler.positionStream.listen((p) => position.value = p);
    _handler.durationStream.listen((d) => duration.value = d ?? Duration.zero);
  }

  Future<void> playQueue(List<Song> songs, int startIndex) =>
      _handler.setQueue(songs, startIndex);

  Future<void> addToQueue(Song song) => _handler.addToQueueSong(song);

  Future<void> addNext(Song song) => _handler.addNextSong(song);

  Future<void> removeFromQueue(int index) => _handler.removeAt(index);

  Future<void> reorderQueue(int oldIndex, int newIndex) =>
      _handler.reorder(oldIndex, newIndex);

  Future<void> jumpTo(int index) => _handler.skipToQueueItem(index);

  Future<void> next() => _handler.skipToNext();

  Future<void> previous() => _handler.skipToPrevious();

  Future<void> playPause() {
    if (currentSong == null) return Future.value();
    return isPlaying.value ? _handler.pause() : _handler.play();
  }

  Future<void> seekTo(Duration pos) => _handler.seek(pos);

  Future<void> clearQueue() => _handler.clearAll();
}
