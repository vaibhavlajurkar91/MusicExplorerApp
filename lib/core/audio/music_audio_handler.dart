import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/song.dart';

/// Whether native playback plugins are available on the current platform.
///
/// `just_audio` and `audio_service` ship no Windows/Linux federated
/// implementation, so touching their method channels there throws
/// `MissingPluginException`. On those platforms the app still runs and keeps
/// its queue/UI state; only the native playback calls are skipped.
bool get audioPlaybackSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Owns the single [ja.AudioPlayer] instance and mirrors its state into
/// audio_service's queue/mediaItem/playbackState so the OS lock-screen and
/// notification stay in sync with in-app playback.
class MusicAudioHandler extends BaseAudioHandler {
  final ja.AudioPlayer? _player =
      audioPlaybackSupported ? ja.AudioPlayer() : null;
  final _songsSubject = BehaviorSubject<List<Song>>.seeded(const []);

  List<Song> _songs = const [];
  int _currentIndex = 0;

  Stream<List<Song>> get songsStream => _songsSubject.stream;
  Stream<Duration> get positionStream =>
      _player?.positionStream ?? const Stream<Duration>.empty();
  Stream<Duration?> get durationStream =>
      _player?.durationStream ?? const Stream<Duration?>.empty();

  Song? get currentSong => _songs.isNotEmpty ? _songs[_currentIndex] : null;
  bool get hasNext => _currentIndex < _songs.length - 1;
  bool get hasPrev => _currentIndex > 0;

  MusicAudioHandler() {
    final player = _player;
    if (player == null) return;
    player.playerStateStream.listen(_broadcastState);
    player.processingStateStream.listen((state) {
      if (state == ja.ProcessingState.completed) {
        if (hasNext) {
          skipToNext();
        } else {
          player.pause();
          player.seek(Duration.zero);
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
    // just_audio's play() only completes when playback pauses/stops/ends, so
    // awaiting it here would hang every caller for the length of the track.
    unawaited(_player?.play());
  }

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> stop() async {
    await _player?.stop();
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
    if ((_player?.position ?? Duration.zero).inSeconds > 3) {
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
    final player = _player;
    if (player == null) return;
    if (song == null || (song.previewUrl?.isEmpty ?? true)) {
      await player.stop();
      return;
    }
    await player.setUrl(song.previewUrl!);
    // Deliberately not awaited: play() completes only when playback ends.
    unawaited(player.play());
  }

  void _publishQueue() {
    final items = [
      for (var i = 0; i < _songs.length; i++) _toMediaItem(_songs[i], i),
    ];
    queue.add(items);
    _songsSubject.add(_songs);
    mediaItem.add(currentSong == null ? null : _toMediaItem(currentSong!, _currentIndex));
    _broadcastState(
      _player?.playerState ??
          ja.PlayerState(false, ja.ProcessingState.idle),
    );
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
      updatePosition: _player?.position ?? Duration.zero,
      bufferedPosition: _player?.bufferedPosition ?? Duration.zero,
      speed: _player?.speed ?? 1.0,
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
