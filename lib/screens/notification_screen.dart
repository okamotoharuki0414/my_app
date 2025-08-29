import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // ダミーの通知データ
  final List<NotificationItem> _notifications = [
    NotificationItem(
      type: NotificationType.like,
      userName: '田中太郎',
      userAvatar: 'https://placehold.co/40x40',
      message: 'があなたの投稿にいいねしました',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      postImage: 'https://placehold.co/60x60',
      isRead: false,
    ),
    NotificationItem(
      type: NotificationType.comment,
      userName: '佐藤花子',
      userAvatar: 'https://placehold.co/40x40',
      message: 'があなたの投稿にコメントしました: "美味しそうですね！"',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      postImage: 'https://placehold.co/60x60',
      isRead: false,
    ),
    NotificationItem(
      type: NotificationType.follow,
      userName: '山田一郎',
      userAvatar: 'https://placehold.co/40x40',
      message: 'があなたをフォローしました',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      type: NotificationType.like,
      userName: '鈴木美咲',
      userAvatar: 'https://placehold.co/40x40',
      message: 'があなたの投稿にいいねしました',
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      postImage: 'https://placehold.co/60x60',
      isRead: true,
    ),
    NotificationItem(
      type: NotificationType.mention,
      userName: '高橋健太',
      userAvatar: 'https://placehold.co/40x40',
      message: 'があなたをメンションしました',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      postImage: 'https://placehold.co/60x60',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '通知',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
            },
            child: Text(
              'すべて既読',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[400], size: 20),
            ),
            // 通知タイプアイコン
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification.userName,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: notification.message,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text(
          _formatTimestamp(notification.timestamp),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: notification.postImage != null
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: Colors.grey[400],
                  size: 20,
                ),
              )
            : notification.type == NotificationType.follow
                ? ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      minimumSize: Size(0, 30),
                    ),
                    child: Text(
                      'フォロー',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : null,
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
        },
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.follow:
        return Colors.green;
      case NotificationType.mention:
        return Colors.orange;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
}

class NotificationItem {
  final NotificationType type;
  final String userName;
  final String userAvatar;
  final String message;
  final DateTime timestamp;
  final String? postImage;
  bool isRead;

  NotificationItem({
    required this.type,
    required this.userName,
    required this.userAvatar,
    required this.message,
    required this.timestamp,
    this.postImage,
    this.isRead = false,
  });
}