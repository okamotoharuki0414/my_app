import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/timeline_screen.dart';
import 'screens/restaurant_feed_screen.dart';
import 'screens/map_search_screen.dart';
import 'screens/simple_google_maps_screen.dart';
import 'screens/test_google_maps_screen.dart';
import 'screens/user_profile_screen.dart';
import 'constants/app_colors.dart';
import 'widgets/custom_restaurant_icon.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
      ),
      home: MainScreen(key: mainScreenKey),
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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
          BottomNavigationBarItem(
            icon: CustomRestaurantIcon(
              size: 32,
              color: _currentIndex == 2 ? Colors.black : Colors.grey,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 32),
            label: '',
          ),
        ],
      ),
    );
  }
}

