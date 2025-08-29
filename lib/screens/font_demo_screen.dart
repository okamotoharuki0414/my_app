import 'package:flutter/material.dart';
import '../constants/app_ikyu_styles.dart';
import '../constants/app_colors.dart';

/// フォント設定のデモンストレーション画面
/// 一休.com風のスタイルを実際に確認できる画面
class FontDemoScreen extends StatelessWidget {
  const FontDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'フォントデモ',
          style: AppIkyuStyles.dishName,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダーセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'レストラン銀座',
                    style: AppIkyuStyles.restaurantName,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restaurant Ginza',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '特選フレンチコース',
                    style: AppIkyuStyles.dishName.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 価格表示セクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '価格表示例',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¥15,800',
                    style: AppIkyuStyles.priceDisplay,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥8,500',
                    style: AppIkyuStyles.priceNormal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥3,200',
                    style: AppIkyuStyles.priceSmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // テキストスタイルセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'テキストスタイル例',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    '本文テキスト（bodyText）',
                    style: AppIkyuStyles.bodyText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'この文章は読みやすさを重視した本文スタイルです。レビューや説明文に最適化されており、長文でも疲れにくい設計になっています。行間とレターカーニングが調整されています。',
                    style: AppIkyuStyles.bodyText,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    '詳細説明テキスト（descriptionText）',
                    style: AppIkyuStyles.descriptionText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'やや小さめのサイズで詳細な情報を表示する際に使用します。補足情報や細かな説明に適しています。',
                    style: AppIkyuStyles.descriptionText,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'レビューテキスト（reviewText）',
                    style: AppIkyuStyles.reviewText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '信頼感を演出するレビュー専用のスタイルです。適度な太さで読みやすく、信頼性を感じさせる設計です。',
                    style: AppIkyuStyles.reviewText,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // キャプション・タイムスタンプセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '補足情報・タイムスタンプ',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'キャプション・補足情報',
                    style: AppIkyuStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    '2024年1月15日 18:30',
                    style: AppIkyuStyles.timestamp,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'プレミアムバッジ',
                      style: AppIkyuStyles.badge,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'フレンチ料理',
                      style: AppIkyuStyles.categoryTag,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ボタンセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ボタンスタイル',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '予約する',
                      style: AppIkyuStyles.buttonText,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '詳細を見る',
                      style: AppIkyuStyles.buttonTextSmall,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // メッセージスタイルセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'メッセージスタイル',
                    style: AppIkyuStyles.dishName,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    '予約が完了しました',
                    style: AppIkyuStyles.successText,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'エラーが発生しました',
                    style: AppIkyuStyles.errorText,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'ご確認ください',
                    style: AppIkyuStyles.warningText,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}