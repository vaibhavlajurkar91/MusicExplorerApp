// Fields are intentionally redeclared so Hive's @HiveField annotations can be
// applied for code generation; they mirror the inherited Song fields.
// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/song.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends Song {
  // State lives on [Song]. These getters exist only to carry the Hive field
  // indices; redeclaring the fields here would shadow the inherited ones and
  // make every instance store each value twice (lint: overridden_fields).
  @override
  @HiveField(0)
  int get trackId => super.trackId;

  @override
  @HiveField(1)
  String get trackName => super.trackName;

  @override
  @HiveField(2)
  String get artistName => super.artistName;

  @override
  @HiveField(3)
  String get collectionName => super.collectionName;

  @override
  @HiveField(4)
  String get artworkUrl100 => super.artworkUrl100;

  @override
  @HiveField(5)
  String? get previewUrl => super.previewUrl;

  @override
  @HiveField(6)
  int? get trackTimeMillis => super.trackTimeMillis;

  @override
  @HiveField(7)
  String? get primaryGenreName => super.primaryGenreName;

  @override
  @HiveField(8)
  DateTime? get releaseDate => super.releaseDate;

  @override
  @HiveField(9)
  int? get artistId => super.artistId;

  @override
  @HiveField(10)
  int? get collectionId => super.collectionId;

  @override
  @HiveField(11)
  int? get trackNumber => super.trackNumber;

  @override
  @HiveField(12)
  int? get discNumber => super.discNumber;

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
    super.artistId,
    super.collectionId,
    super.trackNumber,
    super.discNumber,
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
      artistId: json['artistId'],
      collectionId: json['collectionId'],
      trackNumber: json['trackNumber'],
      discNumber: json['discNumber'],
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
      'artistId': artistId,
      'collectionId': collectionId,
      'trackNumber': trackNumber,
      'discNumber': discNumber,
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
      artistId: song.artistId,
      collectionId: song.collectionId,
      trackNumber: song.trackNumber,
      discNumber: song.discNumber,
    );
  }
}