import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/audio/music_audio_handler.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'data/models/song_model.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(SongModelAdapter());

  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.musicexplorerapp.audio',
      androidNotificationChannelName: 'Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  Get.put<MusicAudioHandler>(audioHandler);

  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Music Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        home: const MainNavigationScreen(),
      ),
    );
  }
}