class Comment {
  final String id;
  final String authorName;
  final String authorHandle;
  final String authorBadge;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.authorBadge,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? authorName,
    String? authorHandle,
    String? authorBadge,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorHandle: authorHandle ?? this.authorHandle,
      authorBadge: authorBadge ?? this.authorBadge,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // 時間の相対的な表示用メソッド
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '今';
    }
  }
}