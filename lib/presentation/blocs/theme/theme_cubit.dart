import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;

  ThemeCubit({required this.prefs}) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = prefs.getBool('is_dark_theme') ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.light;
    prefs.setBool('is_dark_theme', isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
