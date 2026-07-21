import 'package:hive/hive.dart';
import '../../domain/entities/song.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends Song {
  const SongModel({
    required super.trackId,
    required super.trackName,
    required super.artistName,
    required super.collectionName,
    required super.artworkUrl100,
    super.previewUrl,
    super.trackTimeMillis,
    super.primaryGenreName,
    super.releaseDate,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown Artist',
      collectionName: json['collectionName'] ?? 'Unknown Album',
      artworkUrl100: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'],
      trackTimeMillis: json['trackTimeMillis'],
      primaryGenreName: json['primaryGenreName'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
      'trackTimeMillis': trackTimeMillis,
      'primaryGenreName': primaryGenreName,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  factory SongModel.fromEntity(Song song) {
    return SongModel(
      trackId: song.trackId,
      trackName: song.trackName,
      artistName: song.artistName,
      collectionName: song.collectionName,
      artworkUrl100: song.artworkUrl100,
      previewUrl: song.previewUrl,
      trackTimeMillis: song.trackTimeMillis,
      primaryGenreName: song.primaryGenreName,
      releaseDate: song.releaseDate,
    );
  }
}