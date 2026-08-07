import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class AlbumController extends GetxController {
  final SongRepository repository;
  final int collectionId;

  AlbumController({required this.repository, required this.collectionId});

  final _tracks = <Song>[].obs;
  final _isLoading = false.obs;
  final _error = ''.obs;

  List<Song> get tracks => _tracks;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      _tracks.value = await repository.getAlbumTracks(collectionId);
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
