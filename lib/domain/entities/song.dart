import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

class Song extends Equatable {
  @HiveField(0)
  final int trackId;

  @HiveField(1)
  final String trackName;

  @HiveField(2)
  final String artistName;

  @HiveField(3)
  final String collectionName;

  @HiveField(4)
  final String artworkUrl100;

  @HiveField(5)
  final String? previewUrl;

  @HiveField(6)
  final int? trackTimeMillis;

  @HiveField(7)
  final String? primaryGenreName;

  @HiveField(8)
  final DateTime? releaseDate;

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
  });

  String get formattedDuration {
    if (trackTimeMillis == null) return '--:--';
    final d = Duration(milliseconds: trackTimeMillis!);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

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
      ];
}