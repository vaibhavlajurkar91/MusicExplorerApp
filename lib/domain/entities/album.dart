import 'package:equatable/equatable.dart';
import 'song.dart';

class Album extends Equatable {
  final int collectionId;
  final String collectionName;
  final String artistName;
  final String artworkUrl100;
  final int? artistId;
  final int? trackCount;
  final String? primaryGenreName;
  final DateTime? releaseDate;

  const Album({
    required this.collectionId,
    required this.collectionName,
    required this.artistName,
    required this.artworkUrl100,
    this.artistId,
    this.trackCount,
    this.primaryGenreName,
    this.releaseDate,
  });

  /// Builds an album stub from a song, so the album screen can be opened from
  /// anywhere a [Song] is available without a second metadata request.
  static Album? fromSong(Song song) {
    if (song.collectionId == null) return null;
    return Album(
      collectionId: song.collectionId!,
      collectionName: song.collectionName,
      artistName: song.artistName,
      artworkUrl100: song.artworkUrl100,
      artistId: song.artistId,
      primaryGenreName: song.primaryGenreName,
      releaseDate: song.releaseDate,
    );
  }

  @override
  List<Object?> get props => [
        collectionId,
        collectionName,
        artistName,
        artworkUrl100,
        artistId,
        trackCount,
        primaryGenreName,
        releaseDate,
      ];
}
