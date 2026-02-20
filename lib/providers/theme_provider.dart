import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemePreset {
  final String id;
  final String name;
  final Color start;
  final Color end;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const List<AppThemePreset> presets = [
    AppThemePreset(id: 'purple', name: '보라',  start: Color(0xFF667eea), end: Color(0xFF764ba2)),
    AppThemePreset(id: 'blue',   name: '파랑',  start: Color(0xFF1565C0), end: Color(0xFF0288D1)),
    AppThemePreset(id: 'teal',   name: '청록',  start: Color(0xFF00897B), end: Color(0xFF004D40)),
    AppThemePreset(id: 'rose',   name: '장미',  start: Color(0xFFe91e63), end: Color(0xFFad1457)),
    AppThemePreset(id: 'sunset', name: '주황',  start: Color(0xFFFF7043), end: Color(0xFFe64a19)),
  ];

  int _index = 0;

  AppThemePreset get current => presets[_index];
  int get selectedIndex => _index;
  Color get primaryColor => presets[_index].start;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [presets[_index].start, presets[_index].end],
      );

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('app_theme_id') ?? 'purple';
    final idx = presets.indexWhere((p) => p.id == id);
    _index = idx < 0 ? 0 : idx;
    notifyListeners();
  }

  Future<void> selectTheme(int index) async {
    if (index < 0 || index >= presets.length) return;
    _index = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_id', presets[index].id);
  }
}
