import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:musicexplorerapp/core/di/injection.dart';
import 'package:musicexplorerapp/data/models/song_model.dart';
import 'package:musicexplorerapp/main.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    Get.testMode = true;
    hiveDirectory = await Directory.systemTemp.createTemp('music_test_');
    Hive.init(hiveDirectory.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongModelAdapter());
    }
    await DependencyInjection.init();
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
    await Get.reset();
  });

  testWidgets('shows the music explorer home screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Music Explorer'), findsOneWidget);
    expect(find.text('Search for songs...'), findsOneWidget);
  });
}
