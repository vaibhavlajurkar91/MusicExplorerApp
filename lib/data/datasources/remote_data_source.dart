import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album_model.dart';
import '../models/song_model.dart';

class RemoteDataSource {
  final http.Client client;
  static const String host = 'itunes.apple.com';

  RemoteDataSource({required this.client});

  Future<List<SongModel>> searchSongs(
    String query, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await client.get(
        Uri.https(host, '/search', {
          'term': query,
          'entity': 'song',
          'limit': '$limit',
          'offset': '$offset',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => SongModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching songs: $e');
    }
  }

  /// Albums released by an artist, newest first.
  ///
  /// The lookup endpoint returns the artist itself as the first result, so
  /// entries are filtered by `wrapperType` rather than trusting the order.
  Future<List<AlbumModel>> getArtistAlbums(
    int artistId, {
    int limit = 25,
  }) async {
    try {
      final results = await _lookup({
        'id': '$artistId',
        'entity': 'album',
        'limit': '$limit',
      });
      final albums = results
          .where((json) => json['wrapperType'] == 'collection')
          .map((json) => AlbumModel.fromJson(json))
          .toList();

      albums.sort((a, b) {
        final aDate = a.releaseDate;
        final bDate = b.releaseDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return albums;
    } catch (e) {
      throw Exception('Error loading artist albums: $e');
    }
  }

  /// The artist's most popular tracks, in the order iTunes ranks them.
  Future<List<SongModel>> getArtistTopSongs(
    int artistId, {
    int limit = 25,
  }) async {
    try {
      final results = await _lookup({
        'id': '$artistId',
        'entity': 'song',
        'limit': '$limit',
      });
      return results
          .where((json) => json['wrapperType'] == 'track')
          .map((json) => SongModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error loading artist songs: $e');
    }
  }

  /// Every track on an album, ordered by disc then track number.
  ///
  /// iTunes restarts `trackNumber` on each disc, so multi-disc albums must be
  /// ordered by `discNumber` first — sorting on `trackNumber` alone would
  /// interleave the discs (1,1,2,2,…).
  Future<List<SongModel>> getAlbumTracks(int collectionId) async {
    try {
      final results = await _lookup({
        'id': '$collectionId',
        'entity': 'song',
        'limit': '200',
      });
      final tracks = results
          .where((json) => json['wrapperType'] == 'track')
          .map((json) => SongModel.fromJson(json))
          .toList();

      tracks.sort((a, b) {
        final disc = (a.discNumber ?? 1).compareTo(b.discNumber ?? 1);
        if (disc != 0) return disc;
        return (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0);
      });

      return tracks;
    } catch (e) {
      throw Exception('Error loading album tracks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _lookup(
    Map<String, String> queryParameters,
  ) async {
    final response = await client.get(
      Uri.https(host, '/lookup', queryParameters),
    );

    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    return (data['results'] as List).cast<Map<String, dynamic>>();
  }
}