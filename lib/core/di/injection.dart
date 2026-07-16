import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/song_repository_impl.dart';
import '../../domain/repositories/song_repository.dart';
import '../../presentation/controllers/favorites_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/playlist_controller.dart';
import '../../presentation/controllers/player_controller.dart';
import '../../presentation/controllers/recently_played_controller.dart';
import '../../presentation/controllers/theme_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.put(http.Client());

    Get.put<RemoteDataSource>(
      RemoteDataSource(client: Get.find()),
    );

    Get.put<LocalDataSource>(
      LocalDataSource(),
    );

    Get.put<SongRepository>(
      SongRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
    );

    Get.put(ThemeController());

    Get.put(PlayerController(), permanent: true);

    Get.put(HomeController(repository: Get.find()));

    Get.put(FavoritesController(repository: Get.find()));

    Get.put(RecentlyPlayedController(repository: Get.find()));

    Get.put(PlaylistController(repository: Get.find()), permanent: true);
  }
}