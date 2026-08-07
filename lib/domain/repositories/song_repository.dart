import '../entities/album.dart';
import '../entities/playlist.dart';
import '../entities/song.dart';

abstract class SongRepository {
  Future<List<Song>> searchSongs(String query, {int offset = 0, int limit = 20});
  Future<List<Album>> getArtistAlbums(int artistId, {int limit = 25});
  Future<List<Song>> getArtistTopSongs(int artistId, {int limit = 25});
  Future<List<Song>> getAlbumTracks(int collectionId);
  Future<void> addToFavorites(Song song);
  Future<void> removeFromFavorites(int trackId);
  Future<List<Song>> getFavorites();
  Future<bool> isFavorite(int trackId);
  Future<void> addToRecentlyPlayed(Song song);
  Future<List<Song>> getRecentlyPlayed();
  Future<List<Playlist>> getPlaylists();
  Future<void> savePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String id);
  Future<List<String>> getSearchHistory();
  Future<void> addToSearchHistory(String query);
  Future<void> removeFromSearchHistory(String query);
  Future<void> clearSearchHistory();
}