import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../../domain/entities/song.dart';

class PlayerController extends GetxController {
  final _audioPlayer = AudioPlayer();

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
    _audioPlayer.onDurationChanged.listen((d) => duration.value = d);
    _audioPlayer.onPositionChanged.listen((p) => position.value = p);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (hasNext) {
        next();
      } else {
        isPlaying.value = false;
        position.value = Duration.zero;
      }
    });
  }

  Future<void> playQueue(List<Song> songs, int startIndex) async {
    queue.assignAll(songs);
    currentIndex.value = startIndex;
    await _playCurrent();
  }

  Future<void> addToQueue(Song song) async {
    queue.add(song);
    if (!isPlaying.value && queue.length == 1) {
      await _playCurrent();
    }
  }

  Future<void> addNext(Song song) async {
    final insertAt = queue.isEmpty ? 0 : (currentIndex.value + 1).clamp(0, queue.length);
    queue.insert(insertAt, song);
    if (queue.length == 1) await _playCurrent();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= queue.length) return;
    if (index == currentIndex.value) {
      if (hasNext) {
        queue.removeAt(index);
        _playCurrent();
      } else if (hasPrev) {
        currentIndex.value--;
        queue.removeAt(index);
      } else {
        _audioPlayer.stop();
        isPlaying.value = false;
        position.value = Duration.zero;
        duration.value = Duration.zero;
        queue.clear();
      }
    } else {
      if (index < currentIndex.value) currentIndex.value--;
      queue.removeAt(index);
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final song = queue.removeAt(oldIndex);
    queue.insert(newIndex, song);
    if (oldIndex == currentIndex.value) {
      currentIndex.value = newIndex;
    } else if (oldIndex < currentIndex.value && newIndex >= currentIndex.value) {
      currentIndex.value--;
    } else if (oldIndex > currentIndex.value && newIndex <= currentIndex.value) {
      currentIndex.value++;
    }
  }

  Future<void> jumpTo(int index) async {
    if (index < 0 || index >= queue.length) return;
    currentIndex.value = index;
    await _playCurrent();
  }

  Future<void> next() async {
    if (!hasNext) return;
    currentIndex.value++;
    await _playCurrent();
  }

  Future<void> previous() async {
    if (position.value.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (!hasPrev) return;
    currentIndex.value--;
    await _playCurrent();
  }

  Future<void> playPause() async {
    if (currentSong == null) return;
    if (isPlaying.value) {
      await _audioPlayer.pause();
      isPlaying.value = false;
    } else {
      await _audioPlayer.resume();
      isPlaying.value = true;
    }
  }

  Future<void> seekTo(Duration pos) async {
    await _audioPlayer.seek(pos);
  }

  Future<void> clearQueue() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    queue.clear();
    currentIndex.value = 0;
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song == null || (song.previewUrl?.isEmpty ?? true)) {
      isPlaying.value = false;
      return;
    }
    position.value = Duration.zero;
    duration.value = Duration.zero;
    await _audioPlayer.play(UrlSource(song.previewUrl!));
    isPlaying.value = true;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
