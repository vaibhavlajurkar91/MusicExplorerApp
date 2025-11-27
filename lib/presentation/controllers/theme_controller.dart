import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static const String themeBoxName = 'theme';
  static const String themeKey = 'isDarkMode';

  final _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(themeBoxName);
    _isDarkMode.value = box.get(themeKey, defaultValue: false);
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    final box = await Hive.openBox(themeBoxName);
    await box.put(themeKey, _isDarkMode.value);
  }
}