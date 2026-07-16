import 'package:get/get.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class HomeController extends GetxController {
  final SongRepository repository;

  HomeController({required this.repository});

  final _songs = <Song>[].obs;
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _hasMore = true.obs;
  final _searchQuery = 'pop'.obs;
  final _error = ''.obs;
  final _selectedGenre = RxnString('pop');

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  String? get selectedGenre => _selectedGenre.value;

  int _offset = 0;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    searchSongs();
  }

  Future<void> selectGenre(String genre) async {
    _selectedGenre.value = genre;
    await searchSongs(query: genre, fromGenre: true);
  }

  void clearGenreSelection() {
    _selectedGenre.value = null;
  }

  Future<void> searchSongs({String? query, bool fromGenre = false}) async {
    if (query != null) {
      _searchQuery.value = query;
      _songs.clear();
      _offset = 0;
      _hasMore.value = true;
      if (!fromGenre) _selectedGenre.value = null;
    }

    if (_searchQuery.value.isEmpty) return;

    _isLoading.value = true;
    _error.value = '';

    try {
      final results = await repository.searchSongs(
        _searchQuery.value,
        offset: _offset,
        limit: _limit,
      );

      _songs.addAll(results);
      _hasMore.value = results.length >= _limit;
      _offset += results.length;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load songs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreSongs() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    _isLoadingMore.value = true;

    try {
      final results = await repository.searchSongs(
        _searchQuery.value,
        offset: _offset,
        limit: _limit,
      );

      _songs.addAll(results);
      _hasMore.value = results.length >= _limit;
      _offset += results.length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load more songs',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshSongs() async {
    _songs.clear();
    _offset = 0;
    _hasMore.value = true;
    await searchSongs();
  }
}