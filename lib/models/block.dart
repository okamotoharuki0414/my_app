import 'package:cloud_firestore/cloud_firestore.dart';

/// ブロック関係を表すモデル
class Block {
  final String id;
  final String blockerUid;
  final String blockedUid;
  final DateTime createdAt;
  final String? reason;

  Block({
    required this.id,
    required this.blockerUid,
    required this.blockedUid,
    required this.createdAt,
    this.reason,
  });

  factory Block.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Block(
      id: doc.id,
      blockerUid: data['blockerUid'] ?? '',
      blockedUid: data['blockedUid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reason: data['reason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blockerUid': blockerUid,
      'blockedUid': blockedUid,
      'createdAt': FieldValue.serverTimestamp(),
      if (reason != null) 'reason': reason,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block &&
          runtimeType == other.runtimeType &&
          blockerUid == other.blockerUid &&
          blockedUid == other.blockedUid;

  @override
  int get hashCode => blockerUid.hashCode ^ blockedUid.hashCode;
}

/// ユーザーのブロック関係情報
class UserBlockInfo {
  final String uid;
  final Set<String> blockedUids;
  final Set<String> blockedByUids;
  final DateTime lastUpdated;

  UserBlockInfo({
    required this.uid,
    required this.blockedUids,
    required this.blockedByUids,
    required this.lastUpdated,
  });

  bool isBlocking(String targetUid) => blockedUids.contains(targetUid);
  bool isBlockedBy(String targetUid) => blockedByUids.contains(targetUid);
  bool hasBlockRelation(String targetUid) => isBlocking(targetUid) || isBlockedBy(targetUid);

  UserBlockInfo copyWith({
    String? uid,
    Set<String>? blockedUids,
    Set<String>? blockedByUids,
    DateTime? lastUpdated,
  }) {
    return UserBlockInfo(
      uid: uid ?? this.uid,
      blockedUids: blockedUids ?? this.blockedUids,
      blockedByUids: blockedByUids ?? this.blockedByUids,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}