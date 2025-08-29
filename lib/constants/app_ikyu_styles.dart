import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'app_colors.dart';

/// 一休.com風の高級感を演出するテキストスタイル集
/// 
/// 特徴:
/// - 洗練された文字間隔とライン高
/// - 高級感のあるフォントウェイト選択
/// - 読みやすさと美しさのバランス
/// - ナビゲーション要素にはプラットフォーム最適化フォント使用
class AppIkyuStyles {
  
  // ===== プラットフォーム別UIフォント =====
  
  /// ナビゲーション・ボタンなどのUIパーツ用プラットフォーム別フォント
  static String get _uiFontFamily {
    if (Platform.isIOS) {
      return '.AppleSystemUIFont'; // iOS: SF Pro
    } else if (Platform.isAndroid) {
      return 'sans-serif'; // Android: Roboto
    } else {
      return 'Inter'; // その他: Inter
    }
  }

  // ===== 一休.com風メインスタイル（Noto Sans JP使用） =====
  
  /// レストラン名・宿泊施設名などのメイン見出し
  /// 高級感を演出する力強く印象的なスタイル
  static TextStyle get restaurantName => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.8,
  );
  
  /// 料理名・プラン名などのサブ見出し
  /// 上品で読みやすい中見出しスタイル
  static TextStyle get dishName => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.4,
  );
  
  /// 価格表示（特別に目立つスタイル）
  /// 高級感と信頼感を演出する価格表示
  static TextStyle get priceDisplay => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -1.2,
  );
  
  /// 通常価格表示（中サイズ）
  static TextStyle get priceNormal => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.6,
  );
  
  /// 小サイズ価格表示
  static TextStyle get priceSmall => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  /// 本文テキスト（読みやすさ重視）
  /// レビューや説明文に最適化
  static TextStyle get bodyText => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.8,
    letterSpacing: 0.2,
  );
  
  /// 詳細説明テキスト（小サイズ本文）
  static TextStyle get descriptionText => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.15,
  );
  
  /// キャプション・補足情報
  /// 控えめで上品なスタイル
  static TextStyle get caption => GoogleFonts.notoSansJp(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.3,
  );
  
  /// タイムスタンプ・日時表示
  /// シャドウ付きで高級感を演出
  static TextStyle get timestamp => GoogleFonts.notoSansJp(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    shadows: const [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color(0x1A000000),
      ),
    ],
  );
  
  /// バッジ・ステータス表示
  /// 高級感のある強調スタイル
  static TextStyle get badge => GoogleFonts.notoSansJp(
    color: AppColors.secondary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.1,
  );
  
  /// レビュー評価テキスト
  /// 信頼感を演出するスタイル
  static TextStyle get reviewText => GoogleFonts.notoSansJp(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.7,
    letterSpacing: 0.1,
  );
  
  /// カテゴリー・タグ表示
  static TextStyle get categoryTag => GoogleFonts.notoSansJp(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );
  
  // ===== UI要素用スタイル（プラットフォーム最適化） =====
  
  /// アクティブなナビゲーションタブ
  static TextStyle get navigationActive => TextStyle(
    fontFamily: _uiFontFamily,
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  /// 非アクティブなナビゲーションタブ
  static TextStyle get navigationInactive => TextStyle(
    fontFamily: _uiFontFamily,
    color: AppColors.inactive,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.28,
  );
  
  /// ボタンテキスト
  static TextStyle get buttonText => TextStyle(
    fontFamily: _uiFontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.16,
  );
  
  /// ボタンテキスト（小サイズ）
  static TextStyle get buttonTextSmall => TextStyle(
    fontFamily: _uiFontFamily,
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.14,
  );
  
  /// プレースホルダーテキスト
  static TextStyle get placeholder => GoogleFonts.notoSansJp(
    color: AppColors.textPlaceholder,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  // ===== 特殊用途スタイル =====
  
  /// エラーメッセージ
  static TextStyle get errorText => GoogleFonts.notoSansJp(
    color: Colors.red.shade600,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  /// 成功メッセージ
  static TextStyle get successText => GoogleFonts.notoSansJp(
    color: Colors.green.shade600,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  /// 警告メッセージ
  static TextStyle get warningText => GoogleFonts.notoSansJp(
    color: Colors.orange.shade600,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // ===== 後方互換性のためのエイリアス =====
  
  /// 後方互換性: AppTextStyles.heading相当
  static TextStyle get heading => dishName;
  
  /// 後方互換性: AppTextStyles.displayHeading相当
  static TextStyle get displayHeading => restaurantName;
  
  /// 後方互換性: AppTextStyles.body相当
  static TextStyle get body => bodyText;
  
  /// 後方互換性: AppTextStyles.tabActive相当
  static TextStyle get tabActive => navigationActive;
  
  /// 後方互換性: AppTextStyles.tabInactive相当
  static TextStyle get tabInactive => navigationInactive;
}