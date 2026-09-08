import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'user_theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    try {
      final saved = await _storage.read(key: _themeKey);
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      String value = 'system';
      if (mode == ThemeMode.dark) value = 'dark';
      if (mode == ThemeMode.light) value = 'light';
      await _storage.write(key: _themeKey, value: value);
    } catch (_) {}
  }
}
