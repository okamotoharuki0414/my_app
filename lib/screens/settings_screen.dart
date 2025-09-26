import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import 'badge_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // デモ用のユーザーバッジID（実際のアプリでは設定から取得）
  List<String> _userBadgeIds = [
    'expert_reviewer',
    'gourmet_explorer',
    'social_butterfly',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          '設定',
          style: AppTextStyles.heading,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'プロフィール',
            items: [
              _buildSettingItem(
                icon: Icons.workspace_premium,
                title: 'バッジ管理',
                subtitle: '獲得済みバッジと獲得条件を確認',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BadgeManagementScreen(
                        userBadgeIds: _userBadgeIds,
                        onBadgeIdsChanged: (newBadgeIds) {
                          setState(() {
                            _userBadgeIds = newBadgeIds;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.edit,
                title: 'プロフィール編集',
                subtitle: '名前、プロフィール画像、自己紹介を編集',
                onTap: () {
                  // プロフィール編集画面へ遷移
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '通知',
            items: [
              _buildSettingItem(
                icon: Icons.notifications,
                title: '通知設定',
                subtitle: 'プッシュ通知の設定を変更',
                onTap: () {
                  // 通知設定画面へ遷移
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'プライバシー',
            items: [
              _buildSettingItem(
                icon: Icons.security,
                title: 'プライバシー設定',
                subtitle: 'アカウントの公開設定を変更',
                onTap: () {
                  // プライバシー設定画面へ遷移
                },
              ),
              _buildSettingItem(
                icon: Icons.block,
                title: 'ブロック済みユーザー',
                subtitle: 'ブロックしたユーザーの管理',
                onTap: () {
                  // ブロック済みユーザー画面へ遷移
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'サポート',
            items: [
              _buildSettingItem(
                icon: Icons.help,
                title: 'ヘルプ',
                subtitle: 'よくある質問と使い方ガイド',
                onTap: () {
                  // ヘルプ画面へ遷移
                },
              ),
              _buildSettingItem(
                icon: Icons.feedback,
                title: 'フィードバック',
                subtitle: 'アプリの改善提案やバグ報告',
                onTap: () {
                  // フィードバック画面へ遷移
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'アカウント',
            items: [
              _buildSettingItem(
                icon: Icons.logout,
                title: 'ログアウト',
                subtitle: 'アカウントからログアウト',
                onTap: () {
                  _showLogoutDialog();
                },
                textColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                // ログアウト処理
                Navigator.of(context).pop();
                // ログイン画面に戻る（実装は省略）
              },
              child: const Text(
                'ログアウト',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}