import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/song.dart';

/// Owns the single [ja.AudioPlayer] instance and mirrors its state into
/// audio_service's queue/mediaItem/playbackState so the OS lock-screen and
/// notification stay in sync with in-app playback.
class MusicAudioHandler extends BaseAudioHandler {
  final _player = ja.AudioPlayer();
  final _songsSubject = BehaviorSubject<List<Song>>.seeded(const []);

  List<Song> _songs = const [];
  int _currentIndex = 0;

  Stream<List<Song>> get songsStream => _songsSubject.stream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Song? get currentSong => _songs.isNotEmpty ? _songs[_currentIndex] : null;
  bool get hasNext => _currentIndex < _songs.length - 1;
  bool get hasPrev => _currentIndex > 0;

  MusicAudioHandler() {
    _player.playerStateStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ja.ProcessingState.completed) {
        if (hasNext) {
          skipToNext();
        } else {
          _player.pause();
          _player.seek(Duration.zero);
        }
      }
    });
  }

  Future<void> setQueue(List<Song> songs, int startIndex) async {
    _songs = List.of(songs);
    _currentIndex = startIndex;
    _publishQueue();
    await _playCurrent();
  }

  Future<void> addToQueueSong(Song song) async {
    _songs = List.of(_songs)..add(song);
    _publishQueue();
    if (_songs.length == 1) {
      _currentIndex = 0;
      await _playCurrent();
    }
  }

  Future<void> addNextSong(Song song) async {
    final insertAt =
        _songs.isEmpty ? 0 : (_currentIndex + 1).clamp(0, _songs.length);
    _songs = List.of(_songs)..insert(insertAt, song);
    _publishQueue();
    if (_songs.length == 1) {
      _currentIndex = 0;
      await _playCurrent();
    }
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _songs.length) return;
    if (index == _currentIndex) {
      if (hasNext) {
        _songs = List.of(_songs)..removeAt(index);
        _publishQueue();
        await _playCurrent();
      } else if (hasPrev) {
        _currentIndex--;
        _songs = List.of(_songs)..removeAt(index);
        _publishQueue();
      } else {
        _songs = const [];
        _currentIndex = 0;
        _publishQueue();
        await stop();
      }
    } else {
      if (index < _currentIndex) _currentIndex--;
      _songs = List.of(_songs)..removeAt(index);
      _publishQueue();
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final list = List.of(_songs);
    final song = list.removeAt(oldIndex);
    list.insert(newIndex, song);
    _songs = list;
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    _publishQueue();
  }

  Future<void> clearAll() async {
    _songs = const [];
    _currentIndex = 0;
    _publishQueue();
    await stop();
  }

  @override
  Future<void> play() async {
    if (currentSong == null) return;
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (!hasNext) return;
    _currentIndex++;
    await _playCurrent();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (!hasPrev) return;
    _currentIndex--;
    await _playCurrent();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _songs.length) return;
    _currentIndex = index;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    mediaItem.add(song == null ? null : _toMediaItem(song, _currentIndex));
    if (song == null || (song.previewUrl?.isEmpty ?? true)) {
      await _player.stop();
      return;
    }
    await _player.setUrl(song.previewUrl!);
    await _player.play();
  }

  void _publishQueue() {
    final items = [
      for (var i = 0; i < _songs.length; i++) _toMediaItem(_songs[i], i),
    ];
    queue.add(items);
    _songsSubject.add(_songs);
    mediaItem.add(currentSong == null ? null : _toMediaItem(currentSong!, _currentIndex));
    _broadcastState(_player.playerState);
  }

  void _broadcastState(ja.PlayerState playerState) {
    final playing = playerState.playing;
    final controls = <MediaControl>[
      if (hasPrev) MediaControl.skipToPrevious,
      playing ? MediaControl.pause : MediaControl.play,
      if (hasNext) MediaControl.skipToNext,
    ];
    playbackState.add(playbackState.value.copyWith(
      controls: controls,
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: List.generate(controls.length, (i) => i),
      processingState: const {
        ja.ProcessingState.idle: AudioProcessingState.idle,
        ja.ProcessingState.loading: AudioProcessingState.loading,
        ja.ProcessingState.buffering: AudioProcessingState.buffering,
        ja.ProcessingState.ready: AudioProcessingState.ready,
        ja.ProcessingState.completed: AudioProcessingState.completed,
      }[playerState.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    ));
  }

  MediaItem _toMediaItem(Song song, int index) {
    return MediaItem(
      id: '${song.trackId}_$index',
      title: song.trackName,
      artist: song.artistName,
      album: song.collectionName,
      artUri: Uri.tryParse(song.artworkUrl100.replaceAll('100x100', '600x600')),
      duration: song.trackTimeMillis != null
          ? Duration(milliseconds: song.trackTimeMillis!)
          : null,
    );
  }
}
