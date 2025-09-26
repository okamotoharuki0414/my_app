import 'package:flutter/material.dart';
import '../repositories/block_repository.dart';
import '../models/block.dart';
import '../models/post.dart';

/// ブロック機能のビジネスロジック層
class BlockService extends ChangeNotifier {
  UserBlockInfo? _currentBlockInfo;
  bool _isLoading = false;

  UserBlockInfo? get currentBlockInfo => _currentBlockInfo;
  bool get isLoading => _isLoading;

  /// ブロック情報を初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentBlockInfo = await BlockRepository.getUserBlockInfo();
      print('BlockService初期化完了: ${_currentBlockInfo?.blockedUids.length ?? 0}人をブロック中');
    } catch (e) {
      print('BlockService初期化エラー: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ユーザーをブロック
  Future<bool> blockUser(String targetUid, {String? reason}) async {
    print('BlockService.blockUser開始: targetUid=$targetUid, reason=$reason');
    
    if (_currentBlockInfo == null) {
      print('BlockServiceを初期化中...');
      await initialize();
    }
    
    try {
      print('ブロック処理開始...');
      _isLoading = true;
      notifyListeners();

      await BlockRepository.createBlock(
        blockedUid: targetUid,
        reason: reason,
      );
      print('BlockRepository.createBlock完了');

      // ローカル状態を即座に更新
      if (_currentBlockInfo != null) {
        _currentBlockInfo = _currentBlockInfo!.copyWith(
          blockedUids: {..._currentBlockInfo!.blockedUids, targetUid},
          lastUpdated: DateTime.now(),
        );
      }

      notifyListeners();
      print('ブロック処理成功');
      return true;
    } catch (e) {
      print('ブロック実行エラー: $e');
      print('エラー詳細: ${e.runtimeType}');
      if (e is Exception) {
        print('Exception内容: ${e.toString()}');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ユーザーのブロックを解除
  Future<bool> unblockUser(String targetUid) async {
    if (_currentBlockInfo == null) await initialize();
    
    try {
      _isLoading = true;
      notifyListeners();

      await BlockRepository.removeBlock(blockedUid: targetUid);

      // ローカル状態を即座に更新
      if (_currentBlockInfo != null) {
        final updatedBlockedUids = Set<String>.from(_currentBlockInfo!.blockedUids);
        updatedBlockedUids.remove(targetUid);
        _currentBlockInfo = _currentBlockInfo!.copyWith(
          blockedUids: updatedBlockedUids,
          lastUpdated: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('ブロック解除エラー: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 特定のユーザーをブロックしているかチェック
  bool isBlocking(String targetUid) {
    return _currentBlockInfo?.isBlocking(targetUid) ?? false;
  }

  /// 特定のユーザーにブロックされているかチェック
  bool isBlockedBy(String targetUid) {
    return _currentBlockInfo?.isBlockedBy(targetUid) ?? false;
  }

  /// ブロック関係があるかチェック
  bool hasBlockRelation(String targetUid) {
    return _currentBlockInfo?.hasBlockRelation(targetUid) ?? false;
  }

  /// 投稿リストからブロック関係にあるユーザーの投稿を除外
  List<Post> filterBlockedPosts(List<Post> posts) {
    if (_currentBlockInfo == null) return posts;
    
    return posts.where((post) {
      // 投稿者とのブロック関係をチェック
      if (hasBlockRelation(post.authorName)) {
        print('ブロック関係により投稿を除外: ${post.id} from ${post.authorName}');
        return false;
      }
      return true;
    }).toList();
  }

  /// リアルタイムでブロック状態を監視開始
  void startWatching() {
    BlockRepository.watchUserBlockInfo().listen(
      (blockInfo) {
        _currentBlockInfo = blockInfo;
        notifyListeners();
        print('ブロック状態更新: ${blockInfo.blockedUids.length}人をブロック中');
      },
      onError: (e) {
        print('ブロック状態監視エラー: $e');
      },
    );
  }

  /// キャッシュを強制更新
  Future<void> refreshBlockInfo() async {
    BlockRepository.invalidateCache();
    await initialize();
  }

  /// ブロック確認ダイアログを表示
  static Future<bool> showBlockConfirmDialog(
    BuildContext context,
    String userName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ユーザーをブロック'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            children: [
              TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'さんをブロックしますか？\n\n'),
              const TextSpan(
                text: 'ブロックすると:\n'
                    '• お互いの投稿とプロフィールが見えなくなります\n'
                    '• お互いにフォロー、いいね、返信ができなくなります\n'
                    '• DMの送受信ができなくなります\n'
                    '• 相手からの通知が届かなくなります',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ブロック'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// ブロック解除確認ダイアログを表示
  static Future<bool> showUnblockConfirmDialog(
    BuildContext context,
    String userName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブロックを解除'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            children: [
              TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'さんのブロックを解除しますか？\n\n'),
              const TextSpan(
                text: 'ブロックを解除すると、お互いの投稿が再び見えるようになりますが、'
                    'フォロー関係は自動では復元されません。',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ブロック解除'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}