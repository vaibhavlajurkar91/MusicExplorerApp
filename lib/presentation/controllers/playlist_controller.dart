import 'package:get/get.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class PlaylistController extends GetxController {
  final SongRepository repository;

  PlaylistController({required this.repository});

  final _playlists = <Playlist>[].obs;
  final _isLoading = false.obs;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    _isLoading.value = true;
    try {
      final results = await repository.getPlaylists();
      _playlists.value = results;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load playlists',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Playlist?> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: const [],
      createdAt: DateTime.now(),
    );
    try {
      await repository.savePlaylist(playlist);
      _playlists.add(playlist);
      Get.snackbar('Created', 'Playlist "$name" created',
          snackPosition: SnackPosition.BOTTOM);
      return playlist;
    } catch (_) {
      Get.snackbar('Error', 'Failed to create playlist',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    try {
      await repository.deletePlaylist(playlist.id);
      _playlists.removeWhere((p) => p.id == playlist.id);
      Get.snackbar('Deleted', 'Playlist "${playlist.name}" deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete playlist',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    if (playlist.songs.any((s) => s.trackId == song.trackId)) {
      Get.snackbar('Already added', '"${song.trackName}" is already in this playlist',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final updated = playlist.copyWith(songs: [...playlist.songs, song]);
    try {
      await repository.savePlaylist(updated);
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) _playlists[index] = updated;
      Get.snackbar('Added', '"${song.trackName}" added to "${playlist.name}"',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to add song',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    final updated = playlist.copyWith(
      songs: playlist.songs.where((s) => s.trackId != song.trackId).toList(),
    );
    try {
      await repository.savePlaylist(updated);
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) _playlists[index] = updated;
    } catch (_) {
      Get.snackbar('Error', 'Failed to remove song',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> renamePlaylist(Playlist playlist, String newName) async {
    final updated = playlist.copyWith(name: newName);
    try {
      await repository.savePlaylist(updated);
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) _playlists[index] = updated;
    } catch (_) {
      Get.snackbar('Error', 'Failed to rename playlist',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
