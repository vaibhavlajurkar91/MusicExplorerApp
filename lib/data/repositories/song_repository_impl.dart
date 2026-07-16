import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  SongRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Song>> searchSongs(
    String query, {
    int offset = 0,
    int limit = 20,
  }) async {
    return await remoteDataSource.searchSongs(
      query,
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<void> addToFavorites(Song song) async {
    final songModel = SongModel.fromEntity(song);
    await localDataSource.addToFavorites(songModel);
  }

  @override
  Future<void> removeFromFavorites(int trackId) async {
    await localDataSource.removeFromFavorites(trackId);
  }

  @override
  Future<List<Song>> getFavorites() async {
    return await localDataSource.getFavorites();
  }

  @override
  Future<bool> isFavorite(int trackId) async {
    return await localDataSource.isFavorite(trackId);
  }

  @override
  Future<void> addToRecentlyPlayed(Song song) async {
    final songModel = SongModel.fromEntity(song);
    await localDataSource.addToRecentlyPlayed(songModel);
  }

  @override
  Future<List<Song>> getRecentlyPlayed() async {
    return await localDataSource.getRecentlyPlayed();
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    return await localDataSource.getPlaylists();
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    final model = PlaylistModel.fromEntity(playlist);
    await localDataSource.savePlaylist(model);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await localDataSource.deletePlaylist(id);
  }
}