import '../../domain/entities/album.dart';

class AlbumModel extends Album {
  const AlbumModel({
    required super.collectionId,
    required super.collectionName,
    required super.artistName,
    required super.artworkUrl100,
    super.artistId,
    super.trackCount,
    super.primaryGenreName,
    super.releaseDate,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      collectionId: json['collectionId'] ?? 0,
      collectionName: json['collectionName'] ?? 'Unknown Album',
      artistName: json['artistName'] ?? 'Unknown Artist',
      artworkUrl100: json['artworkUrl100'] ?? '',
      artistId: json['artistId'],
      trackCount: json['trackCount'],
      primaryGenreName: json['primaryGenreName'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'])
          : null,
    );
  }
}
