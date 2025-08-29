import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../models/ai_voice.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../screens/comments_screen.dart';
import '../widgets/post_options_overlay.dart';
import '../widgets/star_rating.dart';
import '../widgets/restaurant_info_tab.dart';
import '../widgets/user_badge_widget.dart';
import '../widgets/recruitment_badge.dart';
import '../widgets/event_invitation_card.dart';
import '../widgets/hashtag_text.dart';
import '../screens/dm_comment_screen.dart';
import '../models/restaurant.dart';
import '../widgets/poll_widget.dart';
import '../models/poll.dart';
import '../main.dart';
import '../screens/user_profile_screen.dart';
import '../screens/google_maps_restaurant_detail_screen.dart';
import '../services/user_interest_service.dart';
import '../screens/report_post_screen.dart';
import '../screens/block_user_screen.dart';
import '../screens/report_user_screen.dart';

/// ホーム画面用のPostCard（詳細画面遷移なし、全評価表示）
class PostCardHome extends StatefulWidget {
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

  const PostCardHome({
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
  State<PostCardHome> createState() => _PostCardHomeState();
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

class _PostCardHomeState extends State<PostCardHome> {
  late FlutterTts _flutterTts;
  bool _isReading = false;
  bool _isBgmPlaying = false;
  bool _isAiVoicePlaying = false;
  bool _showOptionsOverlay = false;
  static String? _currentPlayingBgmPostId; // 現在BGM再生中の投稿ID
  static String? _currentPlayingAiVoicePostId; // 現在AI音声再生中の投稿ID

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

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    try {
      // 利用可能な言語を確認
      var languages = await _flutterTts.getLanguages;
      print('利用可能な言語: $languages');
      
      // 利用可能な音声エンジンを確認
      var engines = await _flutterTts.getEngines;
      print('利用可能な音声エンジン: $engines');
      
      // 言語設定（日本語）
      var result = await _flutterTts.setLanguage("ja-JP");
      print('言語設定結果: $result');
      
      // 音量設定（最大）
      await _flutterTts.setVolume(1.0);
      print('音量設定: 1.0');
      
      // 読み上げ速度設定
      await _flutterTts.setSpeechRate(0.5);
      print('読み上げ速度設定: 0.5');
      
      // 音程設定
      await _flutterTts.setPitch(1.0);
      print('音程設定: 1.0');
      
      print('TTS初期化完了 for post: ${widget.post.id}');
    } catch (e) {
      print('TTS初期化エラー: $e');
    }
    
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
        GestureDetector(
          onTap: () {
            // 投稿カードタップ時にコメント画面に遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentsScreen(
                  post: widget.post,
                  onPostUpdated: widget.onPostUpdated,
                ),
              ),
            );
          },
          child: Container(
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
                              // バッジ表示
                              UserBadgeWidget(
                                badgeIds: widget.post.authorBadgeIds,
                                size: 20.0,
                                maxDisplay: 1,
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Text(
                                widget.post.authorName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Text(
                                widget.post.authorBadge,
                                style: AppTextStyles.badge,
                              ),
                            ],
                          ),
                          // 募集バッジ表示
                          if (widget.post.type == PostType.recruitment)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: RecruitmentBadge(),
                            ),
                        ],
                      ),
                    ),
                    // More button
                    IconButton(
                      onPressed: () {
                        print('More button tapped! Showing overlay for post: ${widget.post.id}');
                        setState(() {
                          _showOptionsOverlay = true;
                        });
                      },
                      icon: const Icon(Icons.more_horiz),
                      iconSize: AppDimensions.iconLargeSize,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              
              // Star ratings (if exists) - 全評価表示（ホーム画面用）
              if (widget.post.rating != null && widget.post.rating!.hasAnyRating)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.post.rating!.overall != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: StarRating(rating: widget.post.rating!.overall, label: '総合'),
                        ),
                      if (widget.post.rating!.food != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: StarRating(rating: widget.post.rating!.food, label: '料理'),
                        ),
                      if (widget.post.rating!.service != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: StarRating(rating: widget.post.rating!.service, label: 'サービス'),
                        ),
                      if (widget.post.rating!.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: StarRating(rating: widget.post.rating!.value, label: 'コスパ'),
                        ),
                    ],
                  ),
                ),
              
              // Content with hashtag highlighting
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: HashtagText(
                  text: widget.post.content,
                  style: AppTextStyles.body,
                ),
              ),
              
              // BGM (if exists)
              if (widget.post.bgm != null)
                _buildBgmSection(),
              
              // AI Voice (if exists)
              if (widget.post.aiVoice != null)
                _buildAiVoiceSection(),
              
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
              
              // Poll widget (if exists)
              if (widget.post.poll != null)
                PollWidget(
                  poll: widget.post.poll!,
                  currentUserId: 'user_123', // 現在のユーザーID
                  onVote: (poll, selectedOptions) {
                    // TODO: 投票処理の実装
                    print('Poll vote: $selectedOptions');
                  },
                ),

              // Event invitation card (if exists)
              if (widget.post.event != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: EventInvitationCard(
                    event: widget.post.event!,
                    onAccept: () {
                      print('Event participation accepted');
                    },
                    onDecline: () {
                      print('Event participation declined');
                    },
                    onMaybe: () {
                      print('Event participation maybe');
                    },
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
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => GoogleMapsRestaurantDetailScreen(
                            restaurant: widget.post.restaurant!,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              
              // Action buttons - 投稿カードの一番下に表示
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    // 募集投稿の場合は参加希望ボタン、通常投稿の場合はいいねボタン
                    if (widget.post.type == PostType.recruitment)
                      GestureDetector(
                        onTap: widget.onLike,
                        child: Row(
                          children: [
                            Icon(
                              widget.post.isLiked ? Icons.pan_tool : Icons.pan_tool_outlined,
                              size: 16,
                              color: widget.post.isLiked ? Colors.orange : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              '${widget.post.likeCount}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      )
                    else
                      // 通常投稿のいいねボタン
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
                    
                    // 募集投稿の場合はDMボタン、通常投稿の場合はコメントボタン
                    if (widget.post.type == PostType.recruitment)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DmCommentScreen(
                                post: widget.post,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Text(
                                'チャット',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.showCommentButton)
                      // 通常投稿のコメントボタン
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
                    
                    // イベント投稿の場合のチャットボタン
                    if (widget.post.type == PostType.event)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DmCommentScreen(
                                post: widget.post,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Text(
                                'チャット',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.post.type == PostType.event)
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
            ],
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
      
      // プロフィール画面の保存リストを更新
      if (updatedPost.isSaved) {
        UserProfileScreen.savePost(updatedPost);
      } else {
        UserProfileScreen.unsavePost(updatedPost);
      }
    }
  }

  Widget _buildBgmSection() {
    final bgm = widget.post.bgm!;
    final isCurrentlyPlaying = _currentPlayingBgmPostId == widget.post.id && _isBgmPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 4,
      ),
      child: Row(
        children: [
          // Instagram風の小さな音楽アイコン
          GestureDetector(
            onTap: _toggleBgmPlayback,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCurrentlyPlaying ? Icons.volume_up : Icons.music_note,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${bgm.artist} • ${bgm.title}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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

  Widget _buildAiVoiceSection() {
    final aiVoice = widget.post.aiVoice!;
    final isCurrentlyPlaying = _currentPlayingAiVoicePostId == widget.post.id && _isAiVoicePlaying;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 4,
      ),
      child: Row(
        children: [
          // AI音声アイコンとテキスト
          GestureDetector(
            onTap: _toggleAiVoicePlayback,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCurrentlyPlaying ? Icons.volume_up : Icons.mic,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    aiVoice.iconEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${aiVoice.name} • ${aiVoice.character}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAiVoicePlayback() async {
    setState(() {
      if (_currentPlayingAiVoicePostId == widget.post.id && _isAiVoicePlaying) {
        // 現在の投稿のAI音声が再生中の場合、停止
        _isAiVoicePlaying = false;
        _currentPlayingAiVoicePostId = null;
        print('投稿カードAI音声停止: ${widget.post.id}');
      } else {
        // 他の投稿のAI音声が再生中の場合は停止し、この投稿のAI音声を再生
        _currentPlayingAiVoicePostId = widget.post.id;
        _isAiVoicePlaying = true;
        print('投稿カードAI音声再生開始: ${widget.post.id} - ${widget.post.aiVoice?.name}');
      }
    });

    if (_isAiVoicePlaying && widget.post.aiVoice != null) {
      try {
        print('投稿カード詳細: AI音声再生処理開始 ${widget.post.aiVoice!.name} (${widget.post.aiVoice!.type})');
        
        // 完全に停止してから設定
        await _flutterTts.stop();
        await Future.delayed(Duration(milliseconds: 200));
        
        // AI音声のキャラクターに応じてTTS設定を調整
        await _configureAiVoiceTts(widget.post.aiVoice!);
        
        // サンプルテキストをAI音声風に再生
        print('投稿カード再生開始: "${widget.post.aiVoice!.sampleText}"');
        await _flutterTts.speak(widget.post.aiVoice!.sampleText);
        
        print('投稿カードAI音声再生コマンド送信完了');
      } catch (e) {
        print('投稿カードAI音声再生エラー: $e');
        setState(() {
          _isAiVoicePlaying = false;
          _currentPlayingAiVoicePostId = null;
        });
      }
    } else {
      print('投稿カードAI音声停止処理');
      await _flutterTts.stop();
    }
  }

  Future<void> _configureAiVoiceTts(AiVoice aiVoice) async {
    try {
      print('投稿カードAI音声設定開始: ${aiVoice.name} (${aiVoice.type})');
      
      // 完全に初期化し直す
      await _flutterTts.stop();
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setVolume(1.0);
      
      // TikTok風に極端に違いがある音声設定（選択画面と完全に同じ値）
      switch (aiVoice.type) {
        case VoiceType.cute:
          await _flutterTts.setSpeechRate(0.3); // 極めてゆっくり
          await _flutterTts.setPitch(2.0); // 最高音程
          print('投稿カード - かわいい系設定: 速度0.3, 音程2.0');
          break;
        case VoiceType.funny:
          await _flutterTts.setSpeechRate(1.5); // とても速い
          await _flutterTts.setPitch(0.5); // とても低い
          print('投稿カード - おもしろ系設定: 速度1.5, 音程0.5');
          break;
        case VoiceType.cool:
          await _flutterTts.setSpeechRate(0.6); // ゆっくり
          await _flutterTts.setPitch(0.3); // 極めて低い
          print('投稿カード - クール系設定: 速度0.6, 音程0.3');
          break;
        case VoiceType.mature:
          await _flutterTts.setSpeechRate(0.5); // ゆっくり
          await _flutterTts.setPitch(0.4); // とても低い
          print('投稿カード - 大人系設定: 速度0.5, 音程0.4');
          break;
        case VoiceType.child:
          await _flutterTts.setSpeechRate(1.8); // 極めて速い
          await _flutterTts.setPitch(2.0); // 最高音程
          print('投稿カード - 子供系設定: 速度1.8, 音程2.0');
          break;
        case VoiceType.robot:
          await _flutterTts.setSpeechRate(0.2); // 極めてゆっくり
          await _flutterTts.setPitch(1.0); // 普通
          print('投稿カード - ロボット系設定: 速度0.2, 音程1.0');
          break;
      }
      
      // 設定が反映されるまで十分な時間を待つ
      await Future.delayed(Duration(milliseconds: 500));
      
      print('投稿カードAI音声TTS設定完了: ${aiVoice.name}');
    } catch (e) {
      print('投稿カードAI音声TTS設定エラー: $e');
    }
  }

  Future<void> _handleOptionAction(String action) async {
    setState(() {
      _showOptionsOverlay = false;
    });

    switch (action) {
      case 'not_interested':
        print('投稿に興味がない: ${widget.post.id}');
        await UserInterestService.markPostAsNotInterested(widget.post);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('この投稿に興味がないとマークしました。類似の投稿が表示されにくくなります。'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case 'report_post':
        print('投稿を報告: ${widget.post.id}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportPostScreen(post: widget.post),
          ),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportUserScreen(post: widget.post),
          ),
        );
        break;
      case 'block_account':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlockUserScreen(post: widget.post),
          ),
        );
        break;
    }
  }
}