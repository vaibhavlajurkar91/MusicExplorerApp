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

/// A song plus the identity it keeps for as long as it sits in the queue.
///
/// The same [Song] can be queued more than once, and positions shift on every
/// reorder/removal, so neither the track id nor the list index is a usable
/// identity. [uid] is minted at insertion time and never changes, which is what
/// `ReorderableListView` keys and the published [MediaItem] ids are built from.
@immutable
class QueueEntry {
  const QueueEntry(this.uid, this.song);

  final String uid;
  final Song song;
}

/// Owns the single [ja.AudioPlayer] instance and mirrors its state into
/// audio_service's queue/mediaItem/playbackState so the OS lock-screen and
/// notification stay in sync with in-app playback.
class MusicAudioHandler extends BaseAudioHandler {
  final ja.AudioPlayer? _player =
      audioPlaybackSupported ? ja.AudioPlayer() : null;
  final _queueSubject = BehaviorSubject<List<QueueEntry>>.seeded(const []);
  final _errorSubject = PublishSubject<String>();

  List<QueueEntry> _entries = const [];
  int _currentIndex = 0;
  int _nextUid = 0;

  Stream<List<QueueEntry>> get queueStream => _queueSubject.stream;

  /// Playback failures the UI should surface (dead/expired preview URLs).
  Stream<String> get errorStream => _errorSubject.stream;
  Stream<Duration> get positionStream =>
      _player?.positionStream ?? const Stream<Duration>.empty();
  Stream<Duration?> get durationStream =>
      _player?.durationStream ?? const Stream<Duration?>.empty();

  QueueEntry? get _currentEntry =>
      _entries.isNotEmpty ? _entries[_currentIndex] : null;
  Song? get currentSong => _currentEntry?.song;
  bool get hasNext => _currentIndex < _entries.length - 1;
  bool get hasPrev => _currentIndex > 0;

  QueueEntry _wrap(Song song) => QueueEntry('q${_nextUid++}', song);

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
    _entries = [for (final song in songs) _wrap(song)];
    // Callers pass an index captured at tap time from a list that may have been
    // refiltered since (search results refreshing under a builder index), so an
    // out-of-range value here would make `_currentEntry` throw RangeError from
    // inside a fire-and-forget async call.
    _currentIndex = songs.isEmpty ? 0 : startIndex.clamp(0, songs.length - 1);
    _publishQueue();
    await _playCurrent();
  }

  Future<void> addToQueueSong(Song song) async {
    _entries = List.of(_entries)..add(_wrap(song));
    _publishQueue();
    if (_entries.length == 1) {
      _currentIndex = 0;
      await _playCurrent();
    }
  }

  Future<void> addNextSong(Song song) async {
    final insertAt =
        _entries.isEmpty ? 0 : (_currentIndex + 1).clamp(0, _entries.length);
    _entries = List.of(_entries)..insert(insertAt, _wrap(song));
    _publishQueue();
    if (_entries.length == 1) {
      _currentIndex = 0;
      await _playCurrent();
    }
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _entries.length) return;
    if (index == _currentIndex) {
      if (hasNext) {
        _entries = List.of(_entries)..removeAt(index);
        _publishQueue();
        await _playCurrent();
      } else if (hasPrev) {
        // Removing the currently-playing *last* item: the previous track
        // becomes current, so the player has to be re-pointed at it — without
        // this the removed song keeps playing over the new MediaItem.
        _currentIndex--;
        _entries = List.of(_entries)..removeAt(index);
        _publishQueue();
        await _playCurrent();
      } else {
        _entries = const [];
        _currentIndex = 0;
        _publishQueue();
        await stop();
      }
    } else {
      if (index < _currentIndex) _currentIndex--;
      _entries = List.of(_entries)..removeAt(index);
      _publishQueue();
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final list = List.of(_entries);
    final entry = list.removeAt(oldIndex);
    list.insert(newIndex, entry);
    _entries = list;
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
    _entries = const [];
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
    if (index < 0 || index >= _entries.length) return;
    _currentIndex = index;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final entry = _currentEntry;
    mediaItem.add(entry == null ? null : _toMediaItem(entry));
    // `playbackState` is the only channel PlayerController reads the current
    // index from, and on platforms where `_player` is null nothing else ever
    // pushes to it — so publish here rather than relying on
    // `playerStateStream` firing as a side effect of setUrl/stop.
    _publishCurrentState();
    final player = _player;
    if (player == null) return;
    final song = entry?.song;
    if (song == null || (song.previewUrl?.isEmpty ?? true)) {
      await player.stop();
      return;
    }
    // Callers are fire-and-forget (taps, the completed-track listener), so an
    // escaping rejection would land as an unhandled async error. iTunes preview
    // URLs do 404/expire, so failure here is expected, not exceptional.
    try {
      await player.setUrl(song.previewUrl!);
      // Deliberately not awaited: play() completes only when playback ends.
      unawaited(player.play());
    } catch (_) {
      await player.stop();
      _errorSubject.add('Could not play "${song.trackName}"');
    }
  }

  void _publishQueue() {
    queue.add([for (final entry in _entries) _toMediaItem(entry)]);
    _queueSubject.add(_entries);
    final current = _currentEntry;
    mediaItem.add(current == null ? null : _toMediaItem(current));
    _publishCurrentState();
  }

  /// Pushes the player's current state (or an idle placeholder where there is
  /// no player) onto `playbackState`.
  void _publishCurrentState() => _broadcastState(
        _player?.playerState ?? ja.PlayerState(false, ja.ProcessingState.idle),
      );

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

  /// The id is the entry's stable uid, so a queue mutation that leaves the
  /// current track alone republishes an identical id and listeners can tell a
  /// real track change from a reorder/insert/removal.
  MediaItem _toMediaItem(QueueEntry entry) {
    final song = entry.song;
    return MediaItem(
      id: entry.uid,
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
