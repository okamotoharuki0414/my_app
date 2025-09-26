import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/block.dart';

/// ブロック機能のデータアクセス層
class BlockRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ローカルキャッシュ
  static UserBlockInfo? _cachedBlockInfo;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 現在のユーザーIDを取得（テスト用にダミーIDを使用）
  static String? get _currentUid => _auth.currentUser?.uid ?? 'test_user_123';

  /// ブロック関係を作成（テスト用：ローカルストレージ使用）
  static Future<void> createBlock({
    required String blockedUid,
    String? reason,
  }) async {
    print('BlockRepository.createBlock開始: blockedUid=$blockedUid');
    final currentUid = _currentUid;
    print('現在のUID: $currentUid');
    
    if (currentUid == null) {
      print('認証エラー: ユーザーが認証されていません');
      throw Exception('User not authenticated');
    }
    if (currentUid == blockedUid) {
      print('無効操作: 自分自身をブロックしようとしています');
      throw Exception('Cannot block yourself');
    }

    try {
      // テスト用：ローカルストレージに保存
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList('blocked_users') ?? [];
      
      if (!blockedList.contains(blockedUid)) {
        blockedList.add(blockedUid);
        await prefs.setStringList('blocked_users', blockedList);
        print('ローカルストレージにブロック保存完了: $blockedUid');
      }
      
      // 短時間待機（UIテスト用）
      await Future.delayed(Duration(milliseconds: 500));
      print('ブロック処理完了');
      
      // ローカルキャッシュを更新
      if (_cachedBlockInfo != null) {
        print('ローカルキャッシュ更新中...');
        _cachedBlockInfo = _cachedBlockInfo!.copyWith(
          blockedUids: {..._cachedBlockInfo!.blockedUids, blockedUid},
          lastUpdated: DateTime.now(),
        );
        print('ローカルキャッシュ更新完了');
      }
      
      print('ブロック作成完了: $currentUid -> $blockedUid');
    } catch (e) {
      print('ローカルストレージエラー: $e');
      throw e;
    }
  }

  /// ブロック関係を削除（テスト用：ローカルストレージ使用）
  static Future<void> removeBlock({required String blockedUid}) async {
    final currentUid = _currentUid;
    if (currentUid == null) throw Exception('User not authenticated');

    try {
      print('ブロック解除開始: $blockedUid');
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList('blocked_users') ?? [];
      
      blockedList.remove(blockedUid);
      await prefs.setStringList('blocked_users', blockedList);
      print('ローカルストレージからブロック削除完了: $blockedUid');
      
      // ローカルキャッシュを更新
      if (_cachedBlockInfo != null) {
        final updatedBlockedUids = Set<String>.from(_cachedBlockInfo!.blockedUids);
        updatedBlockedUids.remove(blockedUid);
        _cachedBlockInfo = _cachedBlockInfo!.copyWith(
          blockedUids: updatedBlockedUids,
          lastUpdated: DateTime.now(),
        );
        print('ローカルキャッシュ更新完了');
      }
      
      print('ブロック解除完了: $currentUid -> $blockedUid');
    } catch (e) {
      print('ブロック解除エラー: $e');
      throw e;
    }
  }

  /// ユーザーのブロック情報を取得（テスト用：ローカルストレージ使用）
  static Future<UserBlockInfo> getUserBlockInfo() async {
    final currentUid = _currentUid;
    if (currentUid == null) {
      return UserBlockInfo(
        uid: '',
        blockedUids: {},
        blockedByUids: {},
        lastUpdated: DateTime.now(),
      );
    }

    // キャッシュチェック
    if (_cachedBlockInfo != null && 
        _lastCacheUpdate != null && 
        DateTime.now().difference(_lastCacheUpdate!).compareTo(_cacheValidDuration) < 0) {
      print('キャッシュからブロック情報を返します');
      return _cachedBlockInfo!;
    }

    try {
      print('ローカルストレージからブロック情報を読み込み中...');
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList('blocked_users') ?? [];
      
      final blockedUids = Set<String>.from(blockedList);
      final blockedByUids = <String>{}; // テスト用は空

      final blockInfo = UserBlockInfo(
        uid: currentUid,
        blockedUids: blockedUids,
        blockedByUids: blockedByUids,
        lastUpdated: DateTime.now(),
      );

      // キャッシュを更新
      _cachedBlockInfo = blockInfo;
      _lastCacheUpdate = DateTime.now();

      print('ブロック情報取得完了: blocking=${blockedUids.length}, blocked_by=${blockedByUids.length}');
      return blockInfo;
    } catch (e) {
      print('ブロック情報取得エラー: $e');
      return UserBlockInfo(
        uid: currentUid,
        blockedUids: {},
        blockedByUids: {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// ブロックしているユーザーIDのセットを取得
  static Future<Set<String>> _getBlockedUids(String uid) async {
    final snapshot = await _firestore
        .collection('userBlocks')
        .doc(uid)
        .collection('targets')
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// ブロックされているユーザーIDのセットを取得
  static Future<Set<String>> _getBlockedByUids(String uid) async {
    final snapshot = await _firestore
        .collection('userBlockedBy')
        .doc(uid)
        .collection('sources')
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// 特定のユーザーとのブロック関係をチェック
  static Future<bool> isBlocked(String targetUid) async {
    final blockInfo = await getUserBlockInfo();
    return blockInfo.hasBlockRelation(targetUid);
  }

  /// 特定のユーザーをブロックしているかチェック
  static Future<bool> isBlocking(String targetUid) async {
    final blockInfo = await getUserBlockInfo();
    return blockInfo.isBlocking(targetUid);
  }

  /// キャッシュを無効化
  static void invalidateCache() {
    _cachedBlockInfo = null;
    _lastCacheUpdate = null;
  }

  /// リアルタイムでブロック状態を監視
  static Stream<UserBlockInfo> watchUserBlockInfo() {
    final currentUid = _currentUid;
    if (currentUid == null) {
      return Stream.value(UserBlockInfo(
        uid: '',
        blockedUids: {},
        blockedByUids: {},
        lastUpdated: DateTime.now(),
      ));
    }

    return _firestore
        .collection('userBlocks')
        .doc(currentUid)
        .collection('targets')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUids = snapshot.docs.map((doc) => doc.id).toSet();
      final blockedByUids = await _getBlockedByUids(currentUid);

      final blockInfo = UserBlockInfo(
        uid: currentUid,
        blockedUids: blockedUids,
        blockedByUids: blockedByUids,
        lastUpdated: DateTime.now(),
      );

      // キャッシュを更新
      _cachedBlockInfo = blockInfo;
      _lastCacheUpdate = DateTime.now();

      return blockInfo;
    });
  }
}