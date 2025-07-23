import 'package:flutter/material.dart';
import 'screens/timeline_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
      ),
      home: const TimelineScreen(),
    );
  }
}