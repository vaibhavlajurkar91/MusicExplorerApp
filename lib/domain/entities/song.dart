import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final String artworkUrl100;
  final String? previewUrl;
  final int? trackTimeMillis;
  final String? primaryGenreName;
  final DateTime? releaseDate;
  final int? artistId;
  final int? collectionId;
  final int? trackNumber;

  const Song({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    this.previewUrl,
    this.trackTimeMillis,
    this.primaryGenreName,
    this.releaseDate,
    this.artistId,
    this.collectionId,
    this.trackNumber,
  });

  @override
  List<Object?> get props => [
        trackId,
        trackName,
        artistName,
        collectionName,
        artworkUrl100,
        previewUrl,
        trackTimeMillis,
        primaryGenreName,
        releaseDate,
        artistId,
        collectionId,
        trackNumber,
      ];
}