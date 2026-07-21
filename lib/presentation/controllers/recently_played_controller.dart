import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class RecentlyPlayedController extends GetxController {
  final SongRepository repository;

  RecentlyPlayedController({required this.repository});

  final _songs = <Song>[].obs;
  List<Song> get songs => _songs;

  @override
  void onInit() {
    super.onInit();
    loadRecentlyPlayed();
  }

  Future<void> loadRecentlyPlayed() async {
    _songs.value = await repository.getRecentlyPlayed();
  }

  Future<void> addSong(Song song) async {
    await repository.addToRecentlyPlayed(song);
    await loadRecentlyPlayed();
  }
}
