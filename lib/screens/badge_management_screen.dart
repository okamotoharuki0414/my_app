import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../widgets/user_badge_widget.dart';

class BadgeManagementScreen extends StatefulWidget {
  final List<String> userBadgeIds;
  final Function(List<String>) onBadgeIdsChanged;

  const BadgeManagementScreen({
    super.key,
    required this.userBadgeIds,
    required this.onBadgeIdsChanged,
  });

  @override
  State<BadgeManagementScreen> createState() => _BadgeManagementScreenState();
}

class _BadgeManagementScreenState extends State<BadgeManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _currentBadgeIds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentBadgeIds = List.from(widget.userBadgeIds);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'バッジ管理',
          style: AppTextStyles.heading,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '獲得済み'),
            Tab(text: '未獲得'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onBadgeIdsChanged(_currentBadgeIds);
              Navigator.of(context).pop();
            },
            child: Text(
              '保存',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOwnedBadges(),
          _buildUnownedBadges(),
        ],
      ),
    );
  }

  Widget _buildOwnedBadges() {
    final allBadges = BadgeRepository.getAllBadges();
    final ownedBadges = allBadges
        .where((badge) => _currentBadgeIds.contains(badge.id))
        .toList();

    if (ownedBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'まだバッジを獲得していません',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ownedBadges.length,
      itemBuilder: (context, index) {
        final badge = ownedBadges[index];
        return _buildBadgeCard(badge, true);
      },
    );
  }

  Widget _buildUnownedBadges() {
    final allBadges = BadgeRepository.getAllBadges();
    final unownedBadges = allBadges
        .where((badge) => !_currentBadgeIds.contains(badge.id))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unownedBadges.length,
      itemBuilder: (context, index) {
        final badge = unownedBadges[index];
        return _buildBadgeCard(badge, false);
      },
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isOwned) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwned ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: isOwned ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Badge icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isOwned ? badge.color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              badge.icon,
              color: isOwned ? badge.color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Badge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOwned ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOwned ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOwned ? '獲得済み' : badge.requirement,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOwned ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action button for owned badges
          if (isOwned)
            IconButton(
              onPressed: () {
                setState(() {
                  _currentBadgeIds.remove(badge.id);
                });
              },
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}