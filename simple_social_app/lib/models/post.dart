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
  final bool hasMoreActions;

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
    this.hasMoreActions = true,
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
    bool? hasMoreActions,
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
      hasMoreActions: hasMoreActions ?? this.hasMoreActions,
    );
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}　${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }
}