import 'dart:async';

import 'package:get/get.dart';
import '../../core/audio/music_audio_handler.dart';
import '../../domain/entities/song.dart';

class PlayerController extends GetxController {
  late final MusicAudioHandler _handler;

  Timer? _sleepTimer;
  final _sleepTimerRemaining = Rxn<Duration>();

  Duration? get sleepTimerRemaining => _sleepTimerRemaining.value;
  bool get hasSleepTimer => _sleepTimerRemaining.value != null;

  final queue = <Song>[].obs;

  /// Stable per-entry ids, index-aligned with [queue]. Use these as widget keys
  /// instead of the list index so reorders/removals keep element identity.
  final queueUids = <String>[].obs;
  final currentIndex = 0.obs;
  final isPlaying = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  /// False where no `just_audio` backend ships (Windows/Linux). The queue and
  /// the rest of the app still work there, but every transport call is a no-op,
  /// so the UI must disable/annotate its controls instead of showing live-
  /// looking buttons that do nothing.
  bool get playbackSupported => audioPlaybackSupported;

  /// Message shown next to the disabled controls on those platforms.
  static const unsupportedPlatformMessage =
      'Audio playback is not available on this platform';

  Song? get currentSong =>
      queue.isNotEmpty ? queue[currentIndex.value] : null;
  bool get hasNext => currentIndex.value < queue.length - 1;
  bool get hasPrev => currentIndex.value > 0;

  @override
  void onInit() {
    super.onInit();
    _handler = Get.find<MusicAudioHandler>();

    // Both lists come from the same event so they can never drift apart.
    _handler.queueStream.listen((entries) {
      queue.assignAll([for (final e in entries) e.song]);
      queueUids.assignAll([for (final e in entries) e.uid]);
    });
    _handler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      currentIndex.value = state.queueIndex ?? 0;
    });
    // Only on an actual track change. The handler republishes mediaItem on
    // every queue mutation, and durationStream re-emits only when a new source
    // loads — so resetting on each republish would strand duration at zero for
    // the rest of the track (seek bar pinned right, total time stuck at 00:00).
    _handler.mediaItem.distinct((a, b) => a?.id == b?.id).listen((_) {
      position.value = Duration.zero;
      duration.value = Duration.zero;
    });
    _handler.errorStream.listen((message) {
      Get.snackbar('Playback error', message,
          snackPosition: SnackPosition.BOTTOM);
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

  void setSleepTimer(Duration duration) {
    _clearSleepTimer();
    _sleepTimerRemaining.value = duration;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _sleepTimerRemaining.value;
      if (remaining == null) return;
      if (remaining.inSeconds <= 1) {
        // Pause through the handler so the notification/lock-screen controls
        // reflect the stop too — the timer must not bypass audio_service.
        _handler.pause();
        _clearSleepTimer();
        Get.snackbar('Sleep Timer', 'Playback stopped',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        _sleepTimerRemaining.value = remaining - const Duration(seconds: 1);
      }
    });
  }

  void cancelSleepTimer() {
    _clearSleepTimer();
    Get.snackbar('Sleep Timer', 'Timer cancelled',
        snackPosition: SnackPosition.BOTTOM);
  }

  void _clearSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerRemaining.value = null;
  }

  @override
  void onClose() {
    _clearSleepTimer();
    super.onClose();
  }
}
