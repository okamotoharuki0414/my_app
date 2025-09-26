import 'package:flutter/material.dart';
import 'dart:ui';

enum AppThemeMode {
  system,
  light,
  dark,
  clear,
}

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return _lightTheme; // システムモードはMaterialAppのthemeMode.systemで制御
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.clear:
        return _clearTheme;
    }
  }
  
  // システムモード用のライトテーマ
  static ThemeData get lightTheme => _lightTheme;
  
  // システムモード用のダークテーマ  
  static ThemeData get darkTheme => _darkTheme;

  // ライトモード（Twitter風デザイン）
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1DA1F2), // Twitter Blue
      brightness: Brightness.light,
    ).copyWith(
      background: Colors.white, // Twitter白背景
      surface: Colors.white, // Twitter カード・コンテナ色
      onBackground: const Color(0xFF0F1419), // Twitter濃いテキスト色
      onSurface: const Color(0xFF0F1419), // サーフェス上の文字色
      primary: const Color(0xFF1DA1F2), // Twitter Blue
      onPrimary: Colors.white,
      secondary: const Color(0xFF536471), // Twitter グレーテキスト
      tertiary: const Color(0xFFEFF3F4), // Twitter ライトボーダー色
    ),
    scaffoldBackgroundColor: Colors.white, // Twitter白背景
    fontFamily: 'NotoSansJP',
    textTheme: const TextTheme().apply(
      fontFamily: 'NotoSansJP',
      bodyColor: const Color(0xFF0F1419), // Twitter濃いテキスト色
      displayColor: const Color(0xFF0F1419),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // Twitter AppBar背景（白）
      foregroundColor: Color(0xFF0F1419), // AppBar文字色
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0F1419)), // アイコンカラー
      titleTextStyle: TextStyle(
        color: Color(0xFF0F1419),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansJP',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF1DA1F2), // Twitter Blueで選択状態
      unselectedItemColor: Color(0xFF536471), // Twitter グレー
      backgroundColor: Colors.white, // Twitter白背景
    ),
    cardTheme: const CardThemeData(
      color: Colors.white, // Twitter カード色
      elevation: 0, // Twitterは影なし
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DA1F2), // Twitter Blue
        foregroundColor: Colors.white, // ボタン文字色
        textStyle: const TextStyle(fontFamily: 'NotoSansJP'),
        elevation: 0, // Twitterは影なし
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Twitter風の丸みのあるボタン
        ),
      ),
    ),
    dividerColor: const Color(0xFFEFF3F4), // Twitter ライトボーダー色
  );

  // ダークモード（Twitter風デザイン）
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1DA1F2), // Twitter Blue
      brightness: Brightness.dark,
    ).copyWith(
      background: const Color(0xFF000000), // Twitter黒背景
      surface: const Color(0xFF16181C), // Twitter カード・コンテナ色
      onBackground: Colors.white, // 背景上の文字色
      onSurface: Colors.white, // サーフェス上の文字色
      primary: const Color(0xFF1DA1F2), // Twitter Blue
      onPrimary: Colors.white,
      secondary: const Color(0xFF8B98A5), // Twitter グレーテキスト
      tertiary: const Color(0xFF2F3336), // Twitter ボーダー色
    ),
    scaffoldBackgroundColor: const Color(0xFF000000), // Twitter黒背景
    fontFamily: 'NotoSansJP',
    textTheme: const TextTheme().apply(
      fontFamily: 'NotoSansJP',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000), // Twitter AppBar背景（黒）
      foregroundColor: Colors.white, // AppBar文字色
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white), // アイコンカラー
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansJP',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF1DA1F2), // Twitter Blueで選択状態
      unselectedItemColor: Color(0xFF8B98A5), // Twitter グレー
      backgroundColor: Color(0xFF000000), // Twitter黒背景
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF16181C), // Twitter カード色
      elevation: 0, // Twitterは影なし
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DA1F2), // Twitter Blue
        foregroundColor: Colors.white, // ボタン文字色
        textStyle: const TextStyle(fontFamily: 'NotoSansJP'),
        elevation: 0, // Twitterは影なし
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Twitter風の丸みのあるボタン
        ),
      ),
    ),
    dividerColor: const Color(0xFF2F3336), // Twitter ボーダー色
  );

  // クリアモード（iOS風すりガラス）
  static final ThemeData _clearTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.grey,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'NotoSansJP',
    textTheme: const TextTheme().apply(
      fontFamily: 'NotoSansJP',
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    cardColor: Colors.transparent,
    dividerColor: Color(0x30E1E8ED),
  );

  // クリアモード用の背景ウィジェット
  static Widget clearModeBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F2FD), // Light blue
            Color(0xFFF3E5F5), // Light purple
            Color(0xFFE8F5E8), // Light green
            Color(0xFFFFF3E0), // Light orange
          ],
          stops: [0.0, 0.33, 0.66, 1.0],
        ),
      ),
      child: child,
    );
  }

  // すりガラス効果のContainer（最新仕様）
  static Widget glassMorphismContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // AppBar用のすりガラス効果
  static PreferredSizeWidget glassMorphismAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    double height = 56.0,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: height + MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: AppBar(
              title: Text(title),
              actions: actions,
              leading: leading,
              centerTitle: centerTitle,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // BottomNavigationBar用のすりガラス効果
  static Widget glassMorphismBottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
    required List<BottomNavigationBarItem> items,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}