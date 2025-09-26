import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../constants/app_text_styles.dart';

class FontTestScreen extends StatelessWidget {
  const FontTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String platformName = Platform.operatingSystem;
    String uiFont = Platform.isIOS ? 'SF Pro (iOS)' : 
                   Platform.isAndroid ? 'Roboto (Android)' : 'Inter';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('フォントテスト', style: AppTextStyles.navigationActive),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プラットフォーム情報
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('プラットフォーム: $platformName', style: AppTextStyles.bodyMedium),
                  Text('UI要素フォント: $uiFont', style: AppTextStyles.body),
                  Text('コンテンツフォント: ${AppTextStyles.contentFontFamily}', style: AppTextStyles.body),
                  Text('実際のUI font: ${AppTextStyles.uiFontFamily}', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 様々なフォントサイズのテスト
            const Text('Theme.of(context).textTheme でのテスト:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Text('displayLarge (57px)', style: Theme.of(context).textTheme.displayLarge),
            Text('headlineLarge (32px)', style: Theme.of(context).textTheme.headlineLarge),
            Text('titleLarge (22px)', style: Theme.of(context).textTheme.titleLarge),
            Text('bodyLarge (16px)', style: Theme.of(context).textTheme.bodyLarge),
            Text('bodyMedium (14px)', style: Theme.of(context).textTheme.bodyMedium),
            Text('bodySmall (12px)', style: Theme.of(context).textTheme.bodySmall),
            Text('labelLarge (14px)', style: Theme.of(context).textTheme.labelLarge),
            
            const SizedBox(height: 20),
            Text('Noto Sans JP フォントテスト:',
                 style: AppTextStyles.heading),
            const SizedBox(height: 10),
            
            Text('見出し（Noto Sans JP Semi-Bold）', style: AppTextStyles.heading),
            Text('本文（Noto Sans JP Regular）', style: AppTextStyles.body),
            Text('中見出し（Noto Sans JP Medium）', style: AppTextStyles.bodyMedium),
            Text('¥12,800（価格表示Bold）', style: AppTextStyles.priceText),
            Text('小見出し・ラベル（Medium）', style: AppTextStyles.caption),
            Text('バッジ（Bold）', style: AppTextStyles.badge),
            Text('プレースホルダー（Regular）', style: AppTextStyles.placeholder),
            
            const SizedBox(height: 20),
            Text('プラットフォーム別UI要素:',
                 style: AppTextStyles.heading),
            const SizedBox(height: 10),
            
            Text('ナビゲーション（アクティブ）', style: AppTextStyles.navigationActive),
            Text('ナビゲーション（非アクティブ）', style: AppTextStyles.navigationInactive),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('ボタンテキスト', style: AppTextStyles.buttonText),
            ),
            
            const SizedBox(height: 20),
            const Text('直接指定でのテスト:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // 直接フォントファミリーを指定してテスト
            Text('Noto Sans JP 直接指定テスト:', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            
            Text('Regular (400)', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.w400, fontSize: 16)),
            Text('Medium (500)', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.w500, fontSize: 16)),
            Text('Semi-Bold (600)', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.w600, fontSize: 16)),
            Text('Bold (700)', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.w700, fontSize: 16)),
            
            const SizedBox(height: 15),
            if (Platform.isIOS) ...[
              Text('iOS UI フォント:', style: AppTextStyles.heading),
              const Text('SF Pro Display', 
                        style: TextStyle(fontFamily: '.SF Pro Display', fontSize: 16)),
              const Text('AppleSystemUIFont', 
                        style: TextStyle(fontFamily: '.AppleSystemUIFont', fontSize: 16)),
            ],
            if (Platform.isAndroid) ...[
              Text('Android UI フォント:', style: AppTextStyles.heading),
              const Text('sans-serif (Roboto)', 
                        style: TextStyle(fontFamily: 'sans-serif', fontSize: 16)),
              const Text('Roboto', 
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 16)),
            ],
            
            const SizedBox(height: 20),
            Text('日本語テスト: こんにちは、世界！ 123 ABC', 
                 style: AppTextStyles.body),
            Text('英語テスト: Hello, World! 123 ABC', 
                 style: AppTextStyles.body),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Platform.isIOS ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Platform.isIOS ? Colors.blue : Colors.green,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'フォント設定確認',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Platform.isIOS ? Colors.blue[800] : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('現在のプラットフォーム: ${Platform.operatingSystem}'),
                  Text('コンテンツフォント: ${AppTextStyles.contentFontFamily}'),
                  Text('Theme fontFamily: ${Theme.of(context).textTheme.bodyMedium?.fontFamily ?? "null"}'),
                  const SizedBox(height: 8),
                  Text('✅ コンテンツ: Noto Sans JP', style: AppTextStyles.body),
                  if (Platform.isIOS)
                    Text('✅ UI要素: SF Pro (iOS)', style: AppTextStyles.body),
                  if (Platform.isAndroid)
                    Text('✅ UI要素: Roboto (Android)', style: AppTextStyles.body),
                  if (!Platform.isIOS && !Platform.isAndroid)
                    Text('ℹ️ UI要素: Inter (その他)', style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}