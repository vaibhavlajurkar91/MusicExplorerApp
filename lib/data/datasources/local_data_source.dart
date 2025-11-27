import 'package:hive/hive.dart';
import '../models/song_model.dart';

class LocalDataSource {
  static const String favoritesBoxName = 'favorites';

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
}