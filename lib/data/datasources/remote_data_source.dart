import 'dart:convert';
import 'package:http/http.dart' as http;
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
}