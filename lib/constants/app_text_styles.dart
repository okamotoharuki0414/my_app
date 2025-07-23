import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';
  
  static const TextStyle heading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  
  static const TextStyle timestamp = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.5,
    shadows: [
      Shadow(
        offset: Offset(0, 4),
        blurRadius: 4,
        color: AppColors.shadow,
      ),
    ],
  );
  
  static const TextStyle badge = TextStyle(
    color: AppColors.secondary,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );
  
  static const TextStyle tabActive = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  static const TextStyle tabInactive = TextStyle(
    color: AppColors.inactive,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  static const TextStyle placeholder = TextStyle(
    color: AppColors.textPlaceholder,
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}