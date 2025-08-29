import 'comment.dart';
import 'bgm.dart';
import 'restaurant.dart';
import 'event.dart';
import 'ai_voice.dart';
import 'poll.dart';

class Post {
  final String id;
  final String authorName;
  final String authorBadge;
  final List<String> authorBadgeIds; // ユーザーが獲得したバッジのID
  final String avatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final bool isHidden;
  final bool hasMoreActions;
  final List<Comment> comments;
  final Bgm? bgm; // BGM情報
  final Restaurant? restaurant; // レストラン情報
  final Rating? rating; // 評価情報
  final Event? event; // イベント情報
  final AiVoice? aiVoice; // AI音声情報
  final Poll? poll; // アンケート情報
  final PostType type; // 投稿タイプ

  Post({
    required this.id,
    required this.authorName,
    required this.authorBadge,
    this.authorBadgeIds = const [],
    required this.avatarUrl,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isHidden = false,
    this.hasMoreActions = true,
    this.comments = const [],
    this.bgm,
    this.restaurant,
    this.rating,
    this.event,
    this.aiVoice,
    this.poll,
    this.type = PostType.normal,
  });

  Post copyWith({
    String? id,
    String? authorName,
    String? authorBadge,
    List<String>? authorBadgeIds,
    String? avatarUrl,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isSaved,
    bool? isHidden,
    bool? hasMoreActions,
    List<Comment>? comments,
    Bgm? bgm,
    Restaurant? restaurant,
    Rating? rating,
    Event? event,
    AiVoice? aiVoice,
    Poll? poll,
    PostType? type,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorBadge: authorBadge ?? this.authorBadge,
      authorBadgeIds: authorBadgeIds ?? this.authorBadgeIds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isHidden: isHidden ?? this.isHidden,
      hasMoreActions: hasMoreActions ?? this.hasMoreActions,
      comments: comments ?? this.comments,
      bgm: bgm ?? this.bgm,
      restaurant: restaurant ?? this.restaurant,
      rating: rating ?? this.rating,
      event: event ?? this.event,
      aiVoice: aiVoice ?? this.aiVoice,
      poll: poll ?? this.poll,
      type: type ?? this.type,
    );
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}　${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }
}

// 投稿タイプ
enum PostType {
  normal,      // 通常の投稿
  event,       // イベント投稿
  recruitment, // 募集投稿
}