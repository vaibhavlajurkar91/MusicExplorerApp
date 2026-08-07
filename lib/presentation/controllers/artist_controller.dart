import 'package:get/get.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class ArtistController extends GetxController {
  final SongRepository repository;
  final int artistId;

  ArtistController({required this.repository, required this.artistId});

  final _albums = <Album>[].obs;
  final _topSongs = <Song>[].obs;
  final _isLoading = false.obs;
  final _error = ''.obs;

  List<Album> get albums => _albums;
  List<Song> get topSongs => _topSongs;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isEmpty => _albums.isEmpty && _topSongs.isEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final albumsRequest = repository.getArtistAlbums(artistId);
      final songsRequest = repository.getArtistTopSongs(artistId);

      // Wait on both before reading either, so a failure in one does not leave
      // the other as an unhandled async error.
      await Future.wait([albumsRequest, songsRequest]);

      _albums.value = await albumsRequest;
      _topSongs.value = await songsRequest;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
