import 'package:flutter/material.dart';

enum BadgeType {
  beginner,
  rookie,
  middle,
  expert,
  master,
  legend,
  gourmet,
  foodie,
  explorer,
  social,
  photographer,
  critic,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final IconData icon;
  final Color color;
  final int requiredCount;
  final String requirement;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    required this.requiredCount,
    required this.requirement,
    this.isUnlocked = false,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    BadgeType? type,
    IconData? icon,
    Color? color,
    int? requiredCount,
    String? requirement,
    bool? isUnlocked,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      requiredCount: requiredCount ?? this.requiredCount,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class UserBadge {
  final String userId;
  final String badgeId;
  final DateTime unlockedAt;
  final int currentProgress;

  UserBadge({
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
    this.currentProgress = 0,
  });
}

// バッジデータの定義
class BadgeRepository {
  static List<Badge> getAllBadges() {
    return [
      // レビュー数に基づくバッジ
      Badge(
        id: 'rookie_reviewer',
        name: 'ルーキーレビュワー',
        description: '初めてのレビューを投稿',
        type: BadgeType.rookie,
        icon: Icons.star_outline,
        color: Colors.green,
        requiredCount: 1,
        requirement: '1件のレビューを投稿',
      ),
      Badge(
        id: 'middle_reviewer',
        name: 'ミドルレビュワー',
        description: '多くのレビューを投稿した経験豊富なレビュワー',
        type: BadgeType.middle,
        icon: Icons.star_half,
        color: Colors.blue,
        requiredCount: 10,
        requirement: '10件のレビューを投稿',
      ),
      Badge(
        id: 'expert_reviewer',
        name: 'エキスパートレビュワー',
        description: '数多くの質の高いレビューを投稿',
        type: BadgeType.expert,
        icon: Icons.star,
        color: Colors.purple,
        requiredCount: 50,
        requirement: '50件のレビューを投稿',
      ),
      Badge(
        id: 'master_reviewer',
        name: 'マスターレビュワー',
        description: '圧倒的な数のレビューを投稿した達人',
        type: BadgeType.master,
        icon: Icons.workspace_premium,
        color: Colors.orange,
        requiredCount: 100,
        requirement: '100件のレビューを投稿',
      ),
      Badge(
        id: 'legend_reviewer',
        name: 'レジェンドレビュワー',
        description: '伝説級のレビュー数を誇る最高ランク',
        type: BadgeType.legend,
        icon: Icons.emoji_events,
        color: Colors.amber,
        requiredCount: 500,
        requirement: '500件のレビューを投稿',
      ),

      // 特殊なバッジ
      Badge(
        id: 'gourmet_explorer',
        name: 'グルメエクスプローラー',
        description: '様々なジャンルの料理を探求',
        type: BadgeType.explorer,
        icon: Icons.explore,
        color: Colors.teal,
        requiredCount: 20,
        requirement: '20種類以上のカテゴリのレストランをレビュー',
      ),
      Badge(
        id: 'social_butterfly',
        name: 'ソーシャルバタフライ',
        description: '多くの人とのつながりを大切にする',
        type: BadgeType.social,
        icon: Icons.favorite,
        color: Colors.pink,
        requiredCount: 100,
        requirement: '100件のいいねを獲得',
      ),
      Badge(
        id: 'food_photographer',
        name: 'フードフォトグラファー',
        description: '美しい料理写真を撮影する達人',
        type: BadgeType.photographer,
        icon: Icons.camera_alt,
        color: Colors.indigo,
        requiredCount: 30,
        requirement: '30件の写真付きレビューを投稿',
      ),
      Badge(
        id: 'food_critic',
        name: 'フードクリティック',
        description: '詳細で建設的なレビューを書く専門家',
        type: BadgeType.critic,
        icon: Icons.rate_review,
        color: Colors.deepOrange,
        requiredCount: 25,
        requirement: '平均200文字以上のレビューを25件投稿',
      ),
    ];
  }

  static Badge? getBadgeById(String badgeId) {
    try {
      return getAllBadges().firstWhere((badge) => badge.id == badgeId);
    } catch (e) {
      return null;
    }
  }

  static List<Badge> getUnlockedBadges(List<String> unlockedBadgeIds) {
    return getAllBadges()
        .where((badge) => unlockedBadgeIds.contains(badge.id))
        .toList();
  }
}