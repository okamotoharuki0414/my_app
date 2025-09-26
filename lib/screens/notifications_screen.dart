import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample notifications data
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      type: NotificationType.like,
      fromUser: 'ダニエル',
      fromUserAvatar: 'https://placehold.co/32x32',
      message: 'があなたの投稿にいいねしました',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      isRead: false,
      postImageUrl: 'https://placehold.co/44x44',
    ),
    AppNotification(
      id: '2',
      type: NotificationType.follow,
      fromUser: 'エレナ',
      fromUserAvatar: 'https://placehold.co/32x32',
      message: 'があなたをフォローしました',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.comment,
      fromUser: 'タカシ',
      fromUserAvatar: 'https://placehold.co/32x32',
      message: 'があなたの投稿にコメントしました: "素晴らしい写真ですね！"',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      isRead: true,
      postImageUrl: 'https://placehold.co/44x44',
    ),
    AppNotification(
      id: '4',
      type: NotificationType.like,
      fromUser: 'ユキ',
      fromUserAvatar: 'https://placehold.co/32x32',
      message: 'があなたの投稿にいいねしました',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      postImageUrl: 'https://placehold.co/44x44',
    ),
    AppNotification(
      id: '5',
      type: NotificationType.follow,
      fromUser: 'アヤカ',
      fromUserAvatar: 'https://placehold.co/32x32',
      message: 'があなたをフォローしました',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'アクティビティ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 1,
          tabs: [
            Tab(text: 'フォロー中'),
            Tab(text: 'あなた'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Following tab
          _buildFollowingTab(),
          // You tab (notifications about you)
          _buildYouTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'フォロー中のアクティビティ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'フォローしている人のいいねやコメントが\nここに表示されます',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTab() {
    final newNotifications = _notifications.where((n) => !n.isRead).toList();
    final thisWeek = _notifications.where((n) => n.isRead && 
        n.timestamp.isAfter(DateTime.now().subtract(Duration(days: 7)))).toList();
    final thisMonth = _notifications.where((n) => n.isRead && 
        n.timestamp.isBefore(DateTime.now().subtract(Duration(days: 7)))).toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (newNotifications.isNotEmpty) ...[
          _buildSectionHeader('新着'),
          ...newNotifications.map((notification) => _buildNotificationItem(notification)),
          SizedBox(height: 24),
        ],
        if (thisWeek.isNotEmpty) ...[
          _buildSectionHeader('今週'),
          ...thisWeek.map((notification) => _buildNotificationItem(notification)),
          SizedBox(height: 24),
        ],
        if (thisMonth.isNotEmpty) ...[
          _buildSectionHeader('今月'),
          ...thisMonth.map((notification) => _buildNotificationItem(notification)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: ClipOval(
              child: Image.network(
                notification.fromUserAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: notification.fromUser,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: notification.message,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Action button or post image
          if (notification.type == NotificationType.follow)
            _buildFollowButton()
          else if (notification.postImageUrl != null)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  notification.postImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600], size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF0095F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'フォロー',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日';
    } else {
      return '${difference.inDays ~/ 7}週間';
    }
  }
}