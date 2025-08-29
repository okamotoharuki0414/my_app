class Event {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String organizerId;
  final DateTime dateTime;
  final String location;
  final String locationDetails;
  final int maxParticipants;
  final String? imageUrl;
  final List<String> invitedUserIds;
  final List<String> acceptedUserIds;
  final List<String> declinedUserIds;
  final DateTime createdAt;
  final EventType type;
  final List<String> tags;
  final bool isPublic;
  final EventPrivacy privacy; // プライバシー設定
  final List<String> allowedUserIds; // 選択したユーザーのIDリスト
  final String? requirements; // 参加条件
  final String? notes; // 追加メッセージ

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.organizerId,
    required this.dateTime,
    required this.location,
    required this.locationDetails,
    required this.maxParticipants,
    this.imageUrl,
    required this.invitedUserIds,
    required this.acceptedUserIds,
    required this.declinedUserIds,
    required this.createdAt,
    required this.type,
    required this.tags,
    this.isPublic = true,
    this.privacy = EventPrivacy.public,
    this.allowedUserIds = const [],
    this.requirements,
    this.notes,
  });

  // 参加可能人数
  int get availableSlots => maxParticipants - acceptedUserIds.length;
  
  // 募集中かどうか
  bool get isAcceptingParticipants => availableSlots > 0;
  
  // 開催日時の文字列表現
  String get formattedDateTime {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // 曜日を取得
  String get dayOfWeek {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return '(${days[dateTime.weekday - 1]})';
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizer,
    String? organizerId,
    DateTime? dateTime,
    String? location,
    String? locationDetails,
    int? maxParticipants,
    String? imageUrl,
    List<String>? invitedUserIds,
    List<String>? acceptedUserIds,
    List<String>? declinedUserIds,
    DateTime? createdAt,
    EventType? type,
    List<String>? tags,
    bool? isPublic,
    EventPrivacy? privacy,
    List<String>? allowedUserIds,
    String? requirements,
    String? notes,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      organizerId: organizerId ?? this.organizerId,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageUrl: imageUrl ?? this.imageUrl,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      acceptedUserIds: acceptedUserIds ?? this.acceptedUserIds,
      declinedUserIds: declinedUserIds ?? this.declinedUserIds,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      privacy: privacy ?? this.privacy,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      requirements: requirements ?? this.requirements,
      notes: notes ?? this.notes,
    );
  }
}

enum EventType {
  dining('食事会', '🍽️'),
  party('合コン', '🎉'),
  fan('推し会', '⭐'),
  casual('カジュアル', '☕'),
  business('ビジネス', '💼'),
  cultural('文化・芸術', '🎨'),
  sports('スポーツ', '⚽'),
  other('その他', '📅');

  const EventType(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

// イベント招待状の状態
enum InvitationStatus {
  pending('未回答'),
  accepted('参加'),
  declined('不参加'),
  maybe('検討中');

  const InvitationStatus(this.displayName);
  
  final String displayName;
}

// イベントのプライバシー設定
enum EventPrivacy {
  public('公開', '誰でも参加申請できます'),
  followersOnly('フォロワー限定', 'フォロワーのみ参加申請できます'),
  closeFriendsOnly('親しい友達限定', '親しい友達のみ参加申請できます'),
  selectedUsers('ユーザー選択', '選択したユーザーのみ参加申請できます');

  const EventPrivacy(this.displayName, this.description);
  
  final String displayName;
  final String description;
}