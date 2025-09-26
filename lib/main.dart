import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/timeline_screen.dart';
import 'screens/restaurant_feed_screen.dart';
import 'screens/map_search_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/search_screen.dart';
import 'constants/app_colors.dart';
import 'widgets/custom_restaurant_icon.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_morphism_widgets.dart';
import 'services/user_interest_service.dart';
import 'services/block_service.dart';

// MainScreenのGlobalKey
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable overflow warnings in debug mode
  if (kDebugMode) {
    debugPaintSizeEnabled = false;
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ユーザー興味サービスを初期化
  await UserInterestService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) {
          final blockService = BlockService();
          blockService.initialize();
          blockService.startWatching();
          return blockService;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // デバッグ用：現在のプラットフォームを出力
    if (kDebugMode && !kIsWeb) {
      print('Platform: ${Platform.operatingSystem}');
      print('Font: Using Noto Sans JP for content, platform fonts for UI');
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        Widget app = MaterialApp(
          title: 'Social App',
          debugShowCheckedModeBanner: false,
          // システムモードの場合はtheme/darkTheme/themeModeを設定
          theme: themeProvider.isClearMode 
              ? themeProvider.themeData 
              : themeProvider.lightThemeData,
          darkTheme: themeProvider.darkThemeData,
          themeMode: themeProvider.isClearMode 
              ? ThemeMode.light 
              : themeProvider.themeMode,
          home: MainScreen(key: mainScreenKey),
          routes: {
            '/notifications': (context) => const NotificationsScreen(),
            '/messages': (context) => const MessagesScreen(),
            '/search': (context) => const SearchScreen(),
          },
        );
        
        // クリアモードの場合は背景にグラデーションを追加
        if (themeProvider.isClearMode) {
          return AppTheme.clearModeBackground(child: app);
        }
        
        return app;
      },
    );
  }

}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // プロフィール画面で表示するユーザー情報
  String _profileUserName = 'ダニエル';
  String _profileUserHandle = '@tanaka_gourmet';
  String _profileUserBadge = 'トップレビュワー';
  Color _profileBadgeColor = const Color(0xFFDEAB02);
  
  List<Widget> get _screens => [
    const TimelineScreen(),
    const RestaurantFeedScreen(),
    const MapSearchScreen(),
    UserProfileScreen(
      userName: _profileUserName,
      userHandle: _profileUserHandle,
      userBadge: _profileUserBadge,
      badgeColor: _profileBadgeColor,
    ),
  ];

  // 他のユーザーのプロフィールを表示するメソッド
  void showUserProfile(String userName, String userHandle, String userBadge, Color badgeColor) {
    setState(() {
      _profileUserName = userName;
      _profileUserHandle = userHandle;
      _profileUserBadge = userBadge;
      _profileBadgeColor = badgeColor;
      _currentIndex = 3; // プロフィールタブに切り替え
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassMorphismScaffold(
          isClearMode: themeProvider.isClearMode,
          body: _screens[_currentIndex],
          bottomNavigationBar: GlassMorphismBottomNavigationBar(
            currentIndex: _currentIndex,
            isClearMode: themeProvider.isClearMode,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled, size: 32),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.rate_review_rounded, size: 32),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant, size: 32),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 32),
                label: '',
              ),
            ],
          ),
        );
      },
    );
  }
}

