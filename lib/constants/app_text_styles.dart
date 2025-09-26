import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'app_colors.dart';

class AppTextStyles {
  // ナビゲーション・ボタンなどのUIパーツ用プラットフォーム別フォント
  static String get uiFontFamily {
    if (kIsWeb) {
      return 'Inter';
    } else if (Platform.isIOS) {
      return '.AppleSystemUIFont'; // iOS: SF Pro
    } else if (Platform.isAndroid) {
      return 'sans-serif'; // Android: Roboto
    } else {
      return 'Inter';
    }
  }

  // Noto Sans JPベースのスタイル（本文・見出し用）
  static String get contentFontFamily => 'Noto Sans JP';
  
  // === 高級感を演出するメインスタイル ===
  
  // メイン見出し・店名・重要な情報（洗練されたSemi-Bold）
  static TextStyle get heading => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: -0.3,
  );
  
  // 大見出し（レストラン名・特別な表示用）
  static TextStyle get displayHeading => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.5,
  );
  
  // 本文（読みやすさを重視した上品なRegular）
  static TextStyle get body => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.1,
  );
  
  // 本文中見出し（上品なMedium）
  static TextStyle get bodyMedium => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: -0.1,
  );
  
  // 価格表示（高級感のあるBold・大きめサイズ）
  static TextStyle get priceText => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
  );
  
  // 小見出し・ラベル（品格のあるMedium）
  static TextStyle get caption => GoogleFonts.notoSansJp(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  // タイムスタンプ（上品で控えめなRegular）
  static TextStyle get timestamp => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.2,
    shadows: const [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 2,
        color: AppColors.shadow,
      ),
    ],
  );
  
  // バッジ・ステータス表示（高級感のあるBold）
  static TextStyle get badge => GoogleFonts.notoSansJp(
    color: AppColors.secondary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.1,
  );
  
  // === 特別なコンテンツ用スタイル ===
  
  // レストラン説明・詳細情報（読みやすい本文）
  static TextStyle get description => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.8,
    letterSpacing: 0.15,
  );
  
  // レビュー・評価テキスト（信頼感のあるMedium）
  static TextStyle get reviewText => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.7,
    letterSpacing: 0.05,
  );
  
  // 高級価格表示（特別に大きく・印象的）
  static TextStyle get luxuryPrice => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.8,
  );
  
  // ナビゲーション・ボタン（プラットフォーム別フォント）
  static TextStyle get navigationActive => TextStyle(
    fontFamily: uiFontFamily,
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  static TextStyle get navigationInactive => TextStyle(
    fontFamily: uiFontFamily,
    color: AppColors.inactive,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  // UIボタン用（プラットフォーム別フォント）
  static TextStyle get buttonText => TextStyle(
    fontFamily: uiFontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // プレースホルダー（Noto Sans JP Light）
  static TextStyle get placeholder => GoogleFonts.notoSansJp(
    color: AppColors.textPlaceholder,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // 後方互換性のため
  static TextStyle get tabActive => navigationActive;
  static TextStyle get tabInactive => navigationInactive;
}