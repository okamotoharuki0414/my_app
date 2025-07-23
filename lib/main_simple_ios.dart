import 'package:flutter/material.dart';
import 'screens/timeline_screen.dart';
import 'screens/restaurant_feed_screen.dart';
import 'screens/map_search_screen.dart';
import 'screens/user_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
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
  
  final List<Widget> _screens = [
    const TimelineScreen(),
    const RestaurantFeedScreen(),
    const MapSearchScreen(),
    const UserProfileScreen(
      userName: 'ダニエル',
      userHandle: '@tanaka_gourmet',
      userBadge: 'トップレビュワー',
      badgeColor: Color(0xFFDEAB02),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'タイムライン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'レストラン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'マップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}