import 'package:hive/hive.dart';
import '../../domain/entities/song.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends Song {
  @override
  @HiveField(0)
  final int trackId;

  cocobdon

  @override
  @HiveField(1)
  final String trackName;

  @override
  @HiveField(2)
  final String artistName;

  @override
  @HiveField(3)
  final String collectionName;

  @override
  @HiveField(4)
  final String artworkUrl100;

  @override
  @HiveField(5)
  final String? previewUrl;

  @override
  @HiveField(6)
  final int? trackTimeMillis;

  @override
  @HiveField(7)
  final String? primaryGenreName;

  @override
  @HiveField(8)
  final DateTime? releaseDate;

  const SongModel({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    this.previewUrl,
    this.trackTimeMillis,
    this.primaryGenreName,
    this.releaseDate,
  }) : super(
          trackId: trackId,
          trackName: trackName,
          artistName: artistName,
          collectionName: collectionName,
          artworkUrl100: artworkUrl100,
          previewUrl: previewUrl,
          trackTimeMillis: trackTimeMillis,
          primaryGenreName: primaryGenreName,
          releaseDate: releaseDate,
        );

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