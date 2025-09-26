import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../screens/comments_screen.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/post_options_overlay.dart';
import '../widgets/star_rating.dart';
import '../widgets/restaurant_info_tab.dart';
import '../models/restaurant.dart';
import '../main.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final Function(BuildContext, String)? onShowOptionsMenu;
  final Function(Post)? onPostUpdated;
  final Function(Restaurant)? onRestaurantTap;
  final bool showCommentButton;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onMore,
    this.onShowOptionsMenu,
    this.onPostUpdated,
    this.onRestaurantTap,
    this.showCommentButton = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

// グローバルなTTS管理クラス
class TtsManager {
  static String? _currentReadingPostId;
  static final Map<String, VoidCallback> _listeners = {};
  
  static void setReading(String postId) {
    print('TtsManager.setReading called with postId: $postId');
    _currentReadingPostId = postId;
    _notifyListeners();
  }
  
  static void stopReading() {
    print('TtsManager.stopReading called');
    _currentReadingPostId = null;
    _notifyListeners();
  }
  
  static bool isReading(String postId) {
    return _currentReadingPostId == postId;
  }
  
  static void addListener(String postId, VoidCallback callback) {
    _listeners[postId] = callback;
  }
  
  static void removeListener(String postId) {
    _listeners.remove(postId);
  }
  
  static void _notifyListeners() {
    for (var listener in _listeners.values) {
      listener();
    }
  }
}

class _PostCardState extends State<PostCard> {
  late FlutterTts _flutterTts;
  bool _isReading = false;
  bool _isBgmPlaying = false;
  bool _showOptionsOverlay = false;
  static String? _currentPlayingBgmPostId; // 現在BGM再生中の投稿ID

  @override
  void initState() {
    super.initState();
    _initTts();
    
    // TtsManagerのリスナーに登録
    TtsManager.addListener(widget.post.id, () {
      if (mounted) {
        setState(() {
          _isReading = TtsManager.isReading(widget.post.id);
          print('Post ${widget.post.id} listener called: _isReading=$_isReading');
        });
      }
    });
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    
    // 言語設定（日本語）
    _flutterTts.setLanguage("ja-JP");
    
    // 読み上げ速度設定
    _flutterTts.setSpeechRate(0.5);
    
    // 音程設定
    _flutterTts.setPitch(1.0);
    
    // 読み上げ開始時のハンドラー
    _flutterTts.setStartHandler(() {
      print('TTS Started for post: ${widget.post.id}');
      TtsManager.setReading(widget.post.id);
    });
    
    // 読み上げ完了時のハンドラー
    _flutterTts.setCompletionHandler(() {
      print('TTS Completed for post: ${widget.post.id}');
      TtsManager.stopReading();
    });
    
    // エラー時のハンドラー
    _flutterTts.setErrorHandler((msg) {
      print('TTS Error: $msg');
      TtsManager.stopReading();
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    TtsManager.removeListener(widget.post.id);
    super.dispose();
  }

  void _toggleTts() {
    print('TTS Toggle tapped for post: ${widget.post.id}! Current _isReading: $_isReading');
    
    if (TtsManager.isReading(widget.post.id)) {
      print('Stopping current TTS for post: ${widget.post.id}');
      _flutterTts.stop();
    } else {
      // 他の投稿が読み上げ中なら停止
      if (TtsManager._currentReadingPostId != null) {
        print('Stopping other post TTS...');
        _flutterTts.stop();
      }
      print('Starting TTS for post ${widget.post.id} with content: ${widget.post.content}');
      _flutterTts.speak(widget.post.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimensions.borderThin,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar, name, badge, timestamp
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    // タブバー付きプロフィール画面に切り替え
                    mainScreenKey.currentState?.showUserProfile(
                      widget.post.authorName,
                      '@${widget.post.authorName.toLowerCase()}_user',
                      widget.post.authorBadge.isNotEmpty ? widget.post.authorBadge : 'ユーザー',
                      const Color(0xFFDEAB02),
                    );
                  },
                  child: Container(
                    width: AppDimensions.avatarSize,
                    height: AppDimensions.avatarSize,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                      child: Image.network(
                        widget.post.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.person, size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingLarge),
                // Name and badge column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timestamp
                      Text(
                        widget.post.formattedTimestamp,
                        style: AppTextStyles.timestamp,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      // Name and badge row
                      Row(
                        children: [
                          Container(
                            width: 21,
                            height: 21,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Text(
                            widget.post.authorName,
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Text(
                            widget.post.authorBadge,
                            style: AppTextStyles.badge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More button
                IconButton(
                  onPressed: () {
                    print('More button tapped! Showing overlay for post: ${widget.post.id}');
                    print('Current _showOptionsOverlay: $_showOptionsOverlay');
                    print('Setting _showOptionsOverlay to true');
                    setState(() {
                      _showOptionsOverlay = true;
                    });
                    print('After setState - _showOptionsOverlay: $_showOptionsOverlay');
                  },
                  icon: const Icon(Icons.more_horiz),
                  iconSize: AppDimensions.iconLargeSize,
                  color: Colors.black,
                ),
                    ],
                  ),
                ),
                // Star ratings (if exists) - 最高評価のみ表示
                if (widget.post.rating != null && widget.post.rating!.hasAnyRating)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    child: StarRating(
                      rating: widget.post.rating!.highestRating,
                      label: widget.post.rating!.highestRatingCategory ?? '',
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: Text(
                    widget.post.content,
                    style: AppTextStyles.body,
                  ),
                ),
                // BGM (if exists)
                if (widget.post.bgm != null)
                  _buildBgmSection(),
                // Image (if exists)
                if (widget.post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingLarge,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  child: Image.network(
                    widget.post.imageUrl!,
                    width: AppDimensions.postImageWidth,
                    height: AppDimensions.postImageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: AppDimensions.postImageWidth,
                      height: AppDimensions.postImageHeight,
                      color: AppColors.surface,
                      child: const Icon(Icons.image, size: 48, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          // Restaurant info tab (if exists)
          if (widget.post.restaurant != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: RestaurantInfoTab(
                restaurant: widget.post.restaurant!,
                onTap: () {
                  if (widget.onRestaurantTap != null) {
                    widget.onRestaurantTap!(widget.post.restaurant!);
                  }
                },
              ),
            ),
          // Action buttons - 投稿カードの一番下に表示
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: widget.onLike,
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: widget.post.isLiked ? Colors.red : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        '${widget.post.likeCount}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // Comment button (条件付きで表示)
                if (widget.showCommentButton)
                GestureDetector(
                  onTap: () {
                    print('Comment button tapped!'); // デバッグ用
                    if (widget.onComment != null) {
                      print('Using custom widget.onComment callback');
                      widget.onComment!();
                    } else {
                      print('Navigating to CommentsScreen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            post: widget.post,
                            onPostUpdated: widget.onPostUpdated,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8), // タップエリアを拡大
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          '${widget.post.commentCount}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // TTS (Text-to-Speech) button
                GestureDetector(
                  onTap: _toggleTts,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Builder(
                      builder: (context) {
                        print('Building icon for post ${widget.post.id}: _isReading=$_isReading, color=${_isReading ? "BLACK" : "GREY"}');
                        return Icon(
                          _isReading ? Icons.volume_up : Icons.volume_up_outlined,
                          size: 18,
                          color: _isReading ? Colors.black : AppColors.textSecondary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // Share button
                GestureDetector(
                  onTap: () {
                    print('Share button tapped!'); // デバッグ用
                    if (widget.onShare != null) {
                      print('Using custom widget.onShare callback');
                      widget.onShare!();
                    } else {
                      print('Using default _sharePost method');
                      _sharePost();
                    }
                  },
                  child: SizedBox(
                    width: AppDimensions.iconSize,
                    height: AppDimensions.iconSize,
                    child: Icon(
                      Icons.share,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // Save button
                GestureDetector(
                  onTap: () {
                    print('Save button tapped!'); // デバッグ用
                    if (widget.onSave != null) {
                      print('Using custom widget.onSave callback');
                      widget.onSave!();
                    } else {
                      print('Using default save functionality');
                      _toggleSave();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: widget.post.isSaved ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
        // ローカルオーバーレイ
        if (_showOptionsOverlay)
          Positioned.fill(
            child: Stack(
              children: [
                // 透明な背景（タップでオーバーレイを閉じる）
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOptionsOverlay = false;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                // オプションメニュー（右上に配置、制約あり）
                Positioned(
                  top: 40,
                  right: 10,
                  width: 160,
                  height: 220,
                  child: PostOptionsOverlay(
                    authorName: widget.post.authorName,
                    onDismiss: () {
                      setState(() {
                        _showOptionsOverlay = false;
                      });
                    },
                    onOptionSelected: (String action) {
                      _handleOptionAction(action);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _sharePost() {
    try {
      final String shareText = '${widget.post.authorName}さんの投稿:\n\n'
          '${widget.post.content}\n\n'
          '${widget.post.authorBadge} | ${widget.post.formattedTimestamp}\n\n'
          '🍴 Yumlyで美味しい発見をシェアしよう！';
      
      print('Sharing post: $shareText'); // デバッグ用
      
      Share.share(
        shareText,
        subject: '${widget.post.authorName}さんからのおすすめ',
      );
    } catch (e) {
      print('Error sharing post: $e'); // エラーログ
    }
  }

  void _toggleSave() {
    print('Toggling save state for post: ${widget.post.id}');
    // デフォルトの保存機能
    // 実際のアプリでは、ここで保存状態をトグルし、widget.onPostUpdatedコールバックを呼ぶ
    if (widget.onPostUpdated != null) {
      final updatedPost = widget.post.copyWith(isSaved: !widget.post.isSaved);
      widget.onPostUpdated!(updatedPost);
    }
  }

  Widget _buildBgmSection() {
    final bgm = widget.post.bgm!;
    final isCurrentlyPlaying = _currentPlayingBgmPostId == widget.post.id && _isBgmPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // BGMアルバムアート
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.network(
                  bgm.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
                if (isCurrentlyPlaying)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.equalizer,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // BGM情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bgm.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  bgm.artist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bgm.genre,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bgm.duration,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 再生ボタン
          GestureDetector(
            onTap: _toggleBgmPlayback,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentlyPlaying ? Colors.purple : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                size: 20,
                color: isCurrentlyPlaying ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBgmPlayback() {
    setState(() {
      if (_currentPlayingBgmPostId == widget.post.id && _isBgmPlaying) {
        // 現在の投稿のBGMが再生中の場合、停止
        _isBgmPlaying = false;
        _currentPlayingBgmPostId = null;
        print('BGM paused for post: ${widget.post.id}');
      } else {
        // 他の投稿のBGMが再生中の場合は停止し、この投稿のBGMを再生
        _currentPlayingBgmPostId = widget.post.id;
        _isBgmPlaying = true;
        print('BGM playing for post: ${widget.post.id} - ${widget.post.bgm?.title}');
      }
    });

    // 実際のアプリでは、ここで音楽の再生/停止を行う
    // 例: AudioPlayer.play(widget.post.bgm?.audioUrl);
  }

  void _handleOptionAction(String action) {
    setState(() {
      _showOptionsOverlay = false;
    });

    switch (action) {
      case 'not_interested':
        print('投稿に興味がない: ${widget.post.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('この投稿に興味がないとマークしました')),
        );
        break;
      case 'report_post':
        print('投稿を報告: ${widget.post.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を報告しました')),
        );
        break;
      case 'hide_post':
        print('投稿を非表示: ${widget.post.id}');
        if (widget.onPostUpdated != null) {
          final updatedPost = widget.post.copyWith(isHidden: true);
          widget.onPostUpdated!(updatedPost);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を非表示にしました')),
        );
        break;
      case 'report_account':
        print('アカウントを報告: ${widget.post.authorName}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アカウントを報告しました')),
        );
        break;
      case 'block_account':
        print('アカウントをブロック: ${widget.post.authorName}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アカウントをブロックしました')),
        );
        break;
    }
  }
}