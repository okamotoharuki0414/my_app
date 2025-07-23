import 'comment.dart';
import 'bgm.dart';
import 'restaurant.dart';

class Post {
  final String id;
  final String authorName;
  final String authorBadge;
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

  Post({
    required this.id,
    required this.authorName,
    required this.authorBadge,
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
  });

  Post copyWith({
    String? id,
    String? authorName,
    String? authorBadge,
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
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorBadge: authorBadge ?? this.authorBadge,
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
    );
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}　${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }
}