import 'dart:convert';
import '../../domain/entities/playlist.dart';
import 'song_model.dart';

class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.songs,
    required super.createdAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final songList = (json['songs'] as List<dynamic>)
        .map((s) => SongModel.fromJson(s as Map<String, dynamic>))
        .toList();
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      songs: songList,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'songs': songs
          .map((s) => SongModel.fromEntity(s).toJson())
          .toList(),
    };
  }

  factory PlaylistModel.fromEntity(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      songs: playlist.songs,
      createdAt: playlist.createdAt,
    );
  }

  String serialize() => jsonEncode(toJson());

  factory PlaylistModel.deserialize(String raw) =>
      PlaylistModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
