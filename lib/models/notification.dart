import 'package:flutter/material.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  recruitment,
  event,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String fromUser;
  final String fromUserAvatar;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? postImageUrl;
  final String? postId;

  AppNotification({
    required this.id,
    required this.type,
    required this.fromUser,
    required this.fromUserAvatar,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.postImageUrl,
    this.postId,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? fromUser,
    String? fromUserAvatar,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? postImageUrl,
    String? postId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUser: fromUser ?? this.fromUser,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      postId: postId ?? this.postId,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.like:
        return 'いいね';
      case NotificationType.comment:
        return 'コメント';
      case NotificationType.follow:
        return 'フォロー';
      case NotificationType.mention:
        return 'メンション';
      case NotificationType.recruitment:
        return '募集';
      case NotificationType.event:
        return 'イベント';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.recruitment:
        return Icons.pan_tool;
      case NotificationType.event:
        return Icons.event;
    }
  }
}