import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  AppThemeMode _currentTheme = AppThemeMode.system;

  AppThemeMode get currentTheme => _currentTheme;
  ThemeData get themeData => AppTheme.getTheme(_currentTheme);
  
  // システムモード用のテーマ取得
  ThemeData get lightThemeData => AppTheme.lightTheme;
  ThemeData get darkThemeData => AppTheme.darkTheme;
  
  // ThemeModeを取得（MaterialAppで使用）
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.clear:
        return ThemeMode.light; // クリアモードはライトベース
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  // テーマを変更
  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    notifyListeners();
    await _saveTheme();
  }

  // テーマの保存
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _currentTheme.index);
  }

  // テーマの読み込み
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = AppThemeMode.values[themeIndex];
    notifyListeners();
  }

  // テーマ名を取得
  String get themeName {
    switch (_currentTheme) {
      case AppThemeMode.system:
        return 'システム設定に従う';
      case AppThemeMode.light:
        return 'ライトモード';
      case AppThemeMode.dark:
        return 'ダークモード';
      case AppThemeMode.clear:
        return 'クリアモード';
    }
  }

  // テーマアイコンを取得
  IconData get themeIcon {
    switch (_currentTheme) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.clear:
        return Icons.blur_on;
    }
  }

  // クリアモードかどうか
  bool get isClearMode => _currentTheme == AppThemeMode.clear;

  // ダークモードかどうか
  bool get isDarkMode => _currentTheme == AppThemeMode.dark;
}