import 'package:hive/hive.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class LocalDataSource {
  static const String favoritesBoxName = 'favorites';
  static const String recentlyPlayedBoxName = 'recently_played';
  static const String playlistsBoxName = 'playlists';
  static const int _maxRecentlyPlayed = 20;

  Future<Box<SongModel>> _getFavoritesBox() async {
    return await Hive.openBox<SongModel>(favoritesBoxName);
  }

  Future<void> addToFavorites(SongModel song) async {
    final box = await _getFavoritesBox();
    await box.put(song.trackId.toString(), song);
  }

  Future<void> removeFromFavorites(int trackId) async {
    final box = await _getFavoritesBox();
    await box.delete(trackId.toString());
  }

  Future<List<SongModel>> getFavorites() async {
    final box = await _getFavoritesBox();
    return box.values.toList();
  }

  Future<bool> isFavorite(int trackId) async {
    final box = await _getFavoritesBox();
    return box.containsKey(trackId.toString());
  }

  Future<void> clearFavorites() async {
    final box = await _getFavoritesBox();
    await box.clear();
  }

  Future<Box<SongModel>> _getRecentlyPlayedBox() async {
    return await Hive.openBox<SongModel>(recentlyPlayedBoxName);
  }

  Future<void> addToRecentlyPlayed(SongModel song) async {
    final box = await _getRecentlyPlayedBox();
    final key = song.trackId.toString();
    // Delete first so re-insertion places it at the end (most recent)
    await box.delete(key);
    await box.put(key, song);
    if (box.length > _maxRecentlyPlayed) {
      await box.delete(box.keys.first);
    }
  }

  Future<List<SongModel>> getRecentlyPlayed() async {
    final box = await _getRecentlyPlayedBox();
    return box.values.toList().reversed.toList();
  }

  Future<Box<String>> _getPlaylistsBox() async {
    return await Hive.openBox<String>(playlistsBoxName);
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final box = await _getPlaylistsBox();
    return box.values.map(PlaylistModel.deserialize).toList();
  }

  Future<void> savePlaylist(PlaylistModel playlist) async {
    final box = await _getPlaylistsBox();
    await box.put(playlist.id, playlist.serialize());
  }

  Future<void> deletePlaylist(String id) async {
    final box = await _getPlaylistsBox();
    await box.delete(id);
  }
}