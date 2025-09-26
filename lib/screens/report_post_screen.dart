import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// Twitter風の投稿報告画面
class ReportPostScreen extends StatefulWidget {
  final Post post;

  const ReportPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  final TextEditingController _detailsController = TextEditingController();
  
  // 主要カテゴリ
  final Map<String, List<String>> _reportCategories = {
    'スパムまたは誤解を招くもの': [
      '偽の情報',
      'スパムコンテンツ',
      '不正な広告',
      '詐欺的な内容',
      'その他のスパム行為',
    ],
    '嫌がらせまたは悪用': [
      '攻撃的な言動',
      '嫌がらせ',
      'いじめ',
      '脅迫',
      'ストーカー行為',
    ],
    '暴力的または有害なコンテンツ': [
      '暴力的な脅迫',
      '自傷行為の助長',
      '有害な活動の推進',
      'テロリズムの助長',
      '極端な暴力表現',
    ],
    '不適切なコンテンツ': [
      '成人向けコンテンツ',
      '児童の安全に関わる問題',
      '薬物使用の推進',
      'ヘイトスピーチ',
      'その他の不適切な内容',
    ],
    'プライバシーの侵害': [
      '個人情報の無断公開',
      'プライベート画像の共有',
      'ドクシング（個人特定）',
      'その他のプライバシー侵害',
    ],
    '知的財産権の侵害': [
      '著作権侵害',
      '商標権侵害',
      '偽造品の販売',
      'その他の知的財産権侵害',
    ],
    'その他': [
      '利用規約違反',
      'コミュニティガイドライン違反',
      'その他の問題',
    ],
  };

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  // メール送信機能
  Future<void> _sendReport() async {
    if (_selectedMainCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('報告理由を選択してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // メール本文を構築
    final emailBody = '''
投稿報告

投稿情報:
- 投稿ID: ${widget.post.id}
- 投稿者: ${widget.post.authorName} (${widget.post.authorBadge})
- 投稿内容: "${widget.post.content}"
- 投稿日時: ${widget.post.formattedTimestamp}

報告理由:
- 主カテゴリ: $_selectedMainCategory
- 詳細理由: $_selectedSubCategory

追加詳細:
${_detailsController.text.isNotEmpty ? _detailsController.text : '(なし)'}

---
このメールは自動送信されています。
報告日時: ${DateTime.now().toString()}
    ''';

    // Gmail URI を構築
    final uri = Uri(
      scheme: 'mailto',
      path: 'renarenaremon@gmail.com',
      query: Uri.encodeQueryComponent(
        'subject=投稿報告 - ID: ${widget.post.id}&body=$emailBody',
      ).replaceAll('+', '%20'),
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        
        // 成功メッセージを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('報告を送信しました'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 画面を閉じる
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('メールアプリを開けませんでした');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('メール送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          '投稿を報告',
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
                  // 説明文
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'どのような問題がありますか？',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'この投稿が利用規約やコミュニティガイドラインに違反していると思われる場合は、以下から該当する問題を選択してください。',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 報告対象の投稿プレビュー
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '報告対象の投稿',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(widget.post.avatarUrl),
                              onBackgroundImageError: (exception, stackTrace) {},
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.post.authorName,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    widget.post.authorBadge,
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.content,
                          style: AppTextStyles.caption,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 主カテゴリ選択
                  Text(
                    '問題のカテゴリを選択してください',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ..._reportCategories.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedMainCategory == entry.key
                                ? Colors.blue
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<String>(
                          value: entry.key,
                          groupValue: _selectedMainCategory,
                          onChanged: (value) {
                            setState(() {
                              _selectedMainCategory = value;
                              _selectedSubCategory = null; // リセット
                            });
                          },
                          title: Text(
                            entry.key,
                            style: AppTextStyles.bodyMedium,
                          ),
                          activeColor: Colors.blue,
                          dense: true,
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // サブカテゴリ選択
                  if (_selectedMainCategory != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '具体的な問題を選択してください',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ..._reportCategories[_selectedMainCategory]!.map((subCategory) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedSubCategory == subCategory
                                  ? Colors.blue
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
                            activeColor: Colors.blue,
                            dense: true,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  
                  // 追加詳細入力
                  if (_selectedSubCategory != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '追加の詳細（任意）',
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
                        hintText: '問題についての詳細情報があれば記入してください...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
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
                onPressed: (_selectedMainCategory != null && _selectedSubCategory != null)
                    ? _sendReport
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
                child: Text(
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