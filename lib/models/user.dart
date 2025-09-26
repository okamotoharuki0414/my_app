class User {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String badge;
  final List<String> badgeIds;
  final bool isOnline;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.badge = '',
    this.badgeIds = const [],
    this.isOnline = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? badge,
    List<String>? badgeIds,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      badge: badge ?? this.badge,
      badgeIds: badgeIds ?? this.badgeIds,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}