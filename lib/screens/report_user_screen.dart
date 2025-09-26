import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// ユーザーアカウント報告画面（Twitter風）
class ReportUserScreen extends StatefulWidget {
  final Post post;

  const ReportUserScreen({
    super.key,
    required this.post,
  });

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  String? _selectedCategory;
  String? _selectedSubCategory;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final Map<String, List<String>> _reportCategories = {
    'スパム': [
      'スパムアカウント',
      '宣伝・広告の投稿',
      '偽情報の拡散',
      '繰り返しの迷惑投稿',
    ],
    'ハラスメント': [
      'いじめ・嫌がらせ',
      '脅迫・威嚇',
      '個人情報の暴露',
      'ストーキング行為',
    ],
    '不適切なコンテンツ': [
      'ヌードや性的なコンテンツ',
      '暴力的なコンテンツ',
      'ヘイトスピーチ',
      '自傷行為の促進',
    ],
    'なりすまし': [
      '他の人になりすまし',
      '企業・組織になりすまし',
      '偽の身元情報',
      '詐欺的な行為',
    ],
    'その他': [
      'プライバシーの侵害',
      '著作権侵害',
      'テロリズムの宣伝',
      'その他の違反行為',
    ],
  };

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('報告する問題を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 報告データを作成
      final reportData = {
        'type': 'user_report',
        'reported_user': widget.post.authorName,
        'reporter': 'app_user',
        'timestamp': DateTime.now().toIso8601String(),
        'category': _selectedCategory,
        'sub_category': _selectedSubCategory,
        'details': _detailsController.text.isEmpty ? '詳細なし' : _detailsController.text,
        'post_id': widget.post.id,
        'post_content': widget.post.content,
        'post_timestamp': widget.post.formattedTimestamp,
      };

      print('アカウント報告データを送信中: ${widget.post.authorName}');
      
      // シミュレート用の遅延（実際のアプリではHTTP APIを呼び出し）
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // テスト用：ローカルに報告ログを保存
      print('アカウント報告送信完了: ${json.encode(reportData)}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.post.authorName}さんのアカウントを報告しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('アカウント報告送信エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報告の送信に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'アカウントを報告',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ユーザープレビュー
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(widget.post.avatarUrl),
                          onBackgroundImageError: (exception, stackTrace) {},
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.authorName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.post.authorBadge,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // カテゴリ選択
                  Text(
                    '報告する問題のカテゴリを選択してください',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._reportCategories.keys.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedCategory == category
                                ? Colors.red
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<String>(
                          value: category,
                          groupValue: _selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedSubCategory = null; // サブカテゴリをリセット
                            });
                          },
                          title: Text(
                            category,
                            style: AppTextStyles.bodyMedium,
                          ),
                          activeColor: Colors.red,
                          dense: true,
                        ),
                      ),
                    );
                  }).toList(),

                  // サブカテゴリ選択
                  if (_selectedCategory != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '具体的な問題を選択してください',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._reportCategories[_selectedCategory]!.map((subCategory) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedSubCategory == subCategory
                                  ? Colors.red
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RadioListTile<String>(
                            value: subCategory,
                            groupValue: _selectedSubCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedSubCategory = value;
                              });
                            },
                            title: Text(
                              subCategory,
                              style: AppTextStyles.bodyMedium,
                            ),
                            activeColor: Colors.red,
                            dense: true,
                          ),
                        ),
                      );
                    }).toList(),
                  ],

                  // 詳細入力
                  if (_selectedSubCategory != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '追加詳細（任意）',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '報告する問題の詳細があれば記入してください...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 送信ボタン
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedCategory != null && _selectedSubCategory != null && !_isSubmitting)
                    ? _submitReport
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('送信中...'),
                        ],
                      )
                    : Text(
                        '報告を送信',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}