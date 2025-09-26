import 'package:flutter/material.dart';
import 'dart:io';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/event.dart';
import '../models/ai_voice.dart';
import '../widgets/post_card_home.dart';
import '../widgets/plus_menu.dart';
import '../widgets/inline_plus_menu.dart';
import '../widgets/inline_camera_menu.dart';
import '../widgets/photo_picker_modal.dart';
import '../widgets/post_options_overlay.dart';
import '../screens/photo_edit_screen.dart';
// 不要なマップスクリーンのインポートを削除（要求仕様により）
// import '../screens/simple_google_maps_screen.dart';
// import '../screens/shonan_dai_maps_screen.dart';
// import '../screens/csv_google_maps_screen.dart';
import '../models/bgm.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../widgets/mention_input_widget.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../screens/user_profile_screen.dart';
import '../theme/theme_provider.dart';
import '../widgets/glass_morphism_widgets.dart';
import '../services/user_interest_service.dart';
import 'package:provider/provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool isFollowingTab = true;
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;
  Bgm? _selectedBgm;
  AiVoice? _selectedAiVoice;
  Poll? _selectedPoll;
  bool _isPlusMenuExpanded = false;
  bool _isCameraMenuExpanded = false;
  bool _showOptionsOverlay = false;
  String? _selectedPostId;
  Offset? _overlayPosition;
  bool _isRecruitmentMode = false;
  bool _mentionModeEnabled = false;

  // フォロワーリスト（サンプルデータ）
  final List<User> _followers = [
    User(
      id: '1',
      username: 'yuki_foodie',
      displayName: 'ユキ',
      avatarUrl: 'https://placehold.co/32x32',
      badge: 'フードブロガー',
      badgeIds: ['food_photographer'],
      isOnline: true,
    ),
    User(
      id: '2',
      username: 'daniel_chef',
      displayName: 'ダニエル',
      avatarUrl: 'https://placehold.co/32x32',
      badge: 'トップレビュワー',
      badgeIds: ['master_reviewer', 'gourmet_explorer'],
      isOnline: false,
    ),
    User(
      id: '3',
      username: 'sarah_gourmet',
      displayName: 'サラ',
      avatarUrl: 'https://placehold.co/32x32',
      badge: 'グルメ評論家',
      badgeIds: ['gourmet_critic'],
      isOnline: true,
    ),
  ];

  // フォロー中のユーザーからの投稿
  final List<Post> _followingPosts = [
    // 募集投稿の例
    Post(
      id: '0',
      authorName: 'ユキ',
      authorBadge: 'フードブロガー',
      authorBadgeIds: ['food_photographer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '#募集 お昼ご飯一緒に食べる人いませんか？🍽️\n渋谷駅周辺で美味しいランチスポットを一緒に探索しましょう！',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      likeCount: 8,
      commentCount: 2,
      type: PostType.recruitment,
    ),
    Post(
      id: '1',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      authorBadgeIds: ['master_reviewer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '最高のイタリアンレストランを発見！パスタが絶品でした🍝\n雰囲気も良くて、デートにもおすすめです。',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likeCount: 21,
      commentCount: 3,
      bgm: Bgm(
        id: 'bgm1',
        title: 'Happy Vibes',
        artist: 'DJ Sunny',
        duration: '0:30',
        genre: 'Pop',
        imageUrl: 'https://placehold.co/60x60',
      ),
    ),
    Post(
      id: '000',
      authorName: 'タカシ',
      authorBadge: 'レビュワー',
      authorBadgeIds: ['expert_reviewer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '#募集 新宿でカフェ巡りしませんか？☕\n平日の昼間に時間が空いてる方、一緒にのんびりカフェタイムを楽しみましょう～',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      likeCount: 12,
      commentCount: 4,
      type: PostType.recruitment,
    ),
  ];

  // For youタブ用のおすすめ投稿
  final List<Post> _forYouPosts = [
    // イベント投稿の例
    Post(
      id: 'fy1',
      authorName: 'エレナ',
      authorBadge: 'グルメ',
      authorBadgeIds: ['gourmet_explorer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: 'イベントを作成しました: 週末グルメツアー in 表参道',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      likeCount: 15,
      commentCount: 5,
      type: PostType.event,
      event: Event(
        id: 'event1',
        title: '週末グルメツアー in 表参道',
        description: 'おしゃれな表参道エリアで美味しいお店を巡るグルメツアーを開催します！インスタ映えするカフェやレストランを一緒に楽しみましょう。',
        organizer: 'エレナ',
        organizerId: 'elena_id',
        type: EventType.dining,
        location: '表参道・原宿エリア',
        locationDetails: '表参道駅A1出口集合',
        dateTime: DateTime.now().add(Duration(days: 2)),
        maxParticipants: 8,
        imageUrl: 'https://placehold.co/300x200',
        invitedUserIds: [],
        acceptedUserIds: ['user1', 'user2', 'user3'],
        declinedUserIds: [],
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        tags: ['グルメ', '表参道', 'カフェ'],
      ),
    ),
    // おすすめ募集投稿
    Post(
      id: 'fy2',
      authorName: 'ミユキ',
      authorBadge: 'フードブロガー',
      authorBadgeIds: ['food_photographer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '#募集 今度の土曜日、焼肉食べ放題行きませんか？🥩\n4人以上で割引になるので、一緒に行ける方募集中です！',
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      likeCount: 18,
      commentCount: 7,
      type: PostType.recruitment,
    ),
    // トレンドのレストラン投稿
    Post(
      id: 'fy3',
      authorName: 'ケンジ',
      authorBadge: 'グルメインフルエンサー',
      authorBadgeIds: ['social_butterfly'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '今話題の韓国料理店に行ってきました🇰🇷\nチーズダッカルビが絶品！若い人にめちゃくちゃ人気でした。',
      imageUrl: 'https://placehold.co/287x219',
      timestamp: DateTime.now().subtract(Duration(hours: 8)),
      likeCount: 45,
      commentCount: 12,
    ),
    // 人気のスイーツ投稿
    Post(
      id: 'fy4',
      authorName: 'アヤカ',
      authorBadge: 'レビュワー',
      authorBadgeIds: ['middle_reviewer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '#募集 スイーツ好きな方、パンケーキ巡りしませんか？🥞\n原宿・表参道エリアの有名店を回りたいと思います♪',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      likeCount: 25,
      commentCount: 9,
      type: PostType.recruitment,
    ),
    // 高評価レストラン投稿
    Post(
      id: 'fy5',
      authorName: 'リョウ',
      authorBadge: 'トップレビュワー',
      authorBadgeIds: ['legend_reviewer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '隠れ家的フレンチレストランを発見🍷\nシェフの創作料理が素晴らしく、デートにも最適です。予約困難ですが行く価値あり！',
      imageUrl: 'https://placehold.co/287x219',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      likeCount: 32,
      commentCount: 8,
    ),
  ];

  // 現在表示する投稿を取得
  List<Post> get _currentPosts => isFollowingTab ? _followingPosts : _forYouPosts;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _showOptionsMenu(BuildContext context, String postId) {
    print('_showOptionsMenu called with postId: $postId');
    try {
      final RenderBox button = context.findRenderObject() as RenderBox;
      final Offset buttonPosition = button.localToGlobal(Offset.zero);
      print('Button position: $buttonPosition');
      
      setState(() {
        _showOptionsOverlay = true;
        _selectedPostId = postId;
        _overlayPosition = Offset(
          buttonPosition.dx - 140, // オーバーレイ幅160の大部分を左側に配置
          buttonPosition.dy + 30,  // ボタンの下に配置
        );
      });
      print('Overlay state set: _showOptionsOverlay=$_showOptionsOverlay, position=$_overlayPosition');
    } catch (e) {
      print('Error in _showOptionsMenu: $e');
    }
  }

  void _hideOptionsMenu() {
    setState(() {
      _showOptionsOverlay = false;
      _selectedPostId = null;
      _overlayPosition = null;
    });
  }

  void _handleOptionAction(String action) {
    if (_selectedPostId == null) return;
    
    final currentList = isFollowingTab ? _followingPosts : _forYouPosts;
    final postIndex = currentList.indexWhere((p) => p.id == _selectedPostId);
    if (postIndex == -1) return;
    
    final post = currentList[postIndex];
    
    switch (action) {
      case 'hide_post':
        setState(() {
          currentList[postIndex] = post.copyWith(isHidden: true);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を非表示にしました')),
        );
        break;
      case 'not_interested':
      case 'report_post':
      case 'report_account':
      case 'block_account':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action の処理を実行しました')),
        );
        break;
    }
    
    _hideOptionsMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
          // Header with tabs
          Container(
            height: AppDimensions.headerHeight,
            color: AppColors.background,
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar with search, notification and DM icons
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Search icon on the left
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/search');
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.search,
                              size: 28,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                        // Instagram-style notification icon (heart)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                // Red dot for new notifications
                                Positioned(
                                  top: 6,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF3040),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Instagram-style DM icon (send/messenger)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/messages');
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.rotate(
                                  angle: 0.3, // Slight rotation like Instagram
                                  child: Icon(
                                    Icons.send_outlined,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                                // Red dot for new messages
                                Positioned(
                                  top: 4,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF3040),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    height: AppDimensions.tabBarHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: AppDimensions.paddingMedium,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isFollowingTab = true;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Following',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isFollowingTab ? FontWeight.w700 : FontWeight.w400,
                                      color: isFollowingTab ? Colors.black : Colors.grey[600],
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.paddingSmall),
                                  if (isFollowingTab)
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1DA1F2),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isFollowingTab = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'For you',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: !isFollowingTab ? FontWeight.w700 : FontWeight.w400,
                                      color: !isFollowingTab ? Colors.black : Colors.grey[600],
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.paddingSmall),
                                  if (!isFollowingTab)
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1DA1F2),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                ],
                              ),
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
          // Posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              itemCount: UserInterestService.filterPosts(
                _currentPosts.where((post) => !post.isHidden).toList(),
              ).length,
              itemBuilder: (context, index) {
                // 興味がない投稿と非表示投稿をフィルタリング
                final visiblePosts = UserInterestService.filterPosts(
                  _currentPosts.where((post) => !post.isHidden).toList(),
                );
                final post = visiblePosts[index];
                return PostCardHome(
                  post: post,
                  onShowOptionsMenu: _showOptionsMenu,
                  onLike: () {
                    setState(() {
                      final currentList = isFollowingTab ? _followingPosts : _forYouPosts;
                      final originalIndex = currentList.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        currentList[originalIndex] = post.copyWith(
                          isLiked: !post.isLiked,
                          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                        );
                      }
                    });
                  },
                  onPostUpdated: (updatedPost) {
                    setState(() {
                      final currentList = isFollowingTab ? _followingPosts : _forYouPosts;
                      final originalIndex = currentList.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        currentList[originalIndex] = updatedPost;
                        // 保存状態が変更された場合、プロフィール画面の保存リストも更新
                        if (updatedPost.isSaved != post.isSaved) {
                          if (updatedPost.isSaved) {
                            UserProfileScreen.savePost(updatedPost);
                          } else {
                            UserProfileScreen.unsavePost(updatedPost);
                          }
                        }
                      }
                    });
                  },
                  onSave: () {
                    setState(() {
                      final currentList = isFollowingTab ? _followingPosts : _forYouPosts;
                      final originalIndex = currentList.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        final updatedPost = post.copyWith(isSaved: !post.isSaved);
                        currentList[originalIndex] = updatedPost;
                        
                        // プロフィール画面の保存リストを更新
                        if (updatedPost.isSaved) {
                          UserProfileScreen.savePost(updatedPost);
                        } else {
                          UserProfileScreen.unsavePost(updatedPost);
                        }
                      }
                    });
                    print('Post ${post.id} saved: ${!post.isSaved}');
                  },
                  onMore: () {
                    // Handle more action
                  },
                );
              },
            ),
          ),
          // BGM display area (if BGM is selected)
          if (_selectedBgm != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: AppDimensions.borderRegular,
                  ),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      _selectedBgm!.imageUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 32,
                        height: 32,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedBgm!.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _selectedBgm!.artist,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBgm = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // AI Voice display area (if AI voice is selected)
          if (_selectedAiVoice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: _selectedBgm == null ? BorderSide(
                    color: AppColors.border,
                    width: AppDimensions.borderRegular,
                  ) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _selectedAiVoice!.iconEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedAiVoice!.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _selectedAiVoice!.character,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAiVoice = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Poll display area (if Poll is selected)
          if (_selectedPoll != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: (_selectedBgm == null && _selectedAiVoice == null) ? BorderSide(
                    color: AppColors.border,
                    width: AppDimensions.borderRegular,
                  ) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.poll, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          'アンケート',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPoll!.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPoll = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Post input area
          Container(
            height: _isRecruitmentMode ? AppDimensions.bottomInputHeight + 30 : AppDimensions.bottomInputHeight,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: (_selectedBgm == null && _selectedAiVoice == null && _selectedPoll == null) ? BorderSide(
                  color: AppColors.border,
                  width: AppDimensions.borderRegular,
                ) : BorderSide.none,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.borderRadiusMedium),
                topRight: Radius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlusMenuExpanded = !_isPlusMenuExpanded;
                        // カメラメニューを閉じる
                        if (_isPlusMenuExpanded) {
                          _isCameraMenuExpanded = false;
                        }
                      });
                    },
                    child: Container(
                      width: AppDimensions.iconContainerSize,
                      height: AppDimensions.iconContainerSize,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                      ),
                      child: AnimatedRotation(
                        turns: _isPlusMenuExpanded ? 0.125 : 0, // 45度回転
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Camera button
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCameraMenuExpanded = !_isCameraMenuExpanded;
                        // プラスメニューを閉じる
                        if (_isCameraMenuExpanded) {
                          _isPlusMenuExpanded = false;
                        }
                      });
                    },
                    child: Container(
                      width: AppDimensions.iconContainerSize,
                      height: AppDimensions.iconContainerSize,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                      ),
                      child: AnimatedRotation(
                        turns: _isCameraMenuExpanded ? 0.125 : 0, // 45度回転
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.photo_camera,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Text input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    child: TextField(
                          controller: _postController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: true,
                          autocorrect: true,
                          decoration: InputDecoration(
                            hintText: '投稿内容を入力',
                            hintStyle: AppTextStyles.placeholder,
                            border: InputBorder.none,
                          ),
                          style: AppTextStyles.body,
                          onChanged: (value) {
                            setState(() {
                              // Update UI when text changes
                            });
                          },
                        ),
                  ),
                ),
                // Send button
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: GestureDetector(
                    onTap: (_postController.text.isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null) ? () {
                      // Handle post submission
                      _submitPost();
                    } : null,
                    child: Container(
                      width: AppDimensions.iconLargeSize,
                      height: AppDimensions.iconLargeSize,
                      child: Icon(
                        Icons.send,
                        size: 20,
                        color: (_postController.text.isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null)
                            ? Colors.black 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // インラインメニュー - 投稿欄の下に展開
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPlusMenuExpanded)
                InlinePlusMenu(
                  isExpanded: _isPlusMenuExpanded,
                  onToggle: () {
                    setState(() {
                      _isPlusMenuExpanded = false;
                    });
                  },
                  onBgmSelected: (bgm) {
                    setState(() {
                      _selectedBgm = bgm;
                    });
                    print('BGM selected: ${bgm.title} by ${bgm.artist}');
                  },
                  onAiVoiceSelected: (aiVoice) {
                    setState(() {
                      _selectedAiVoice = aiVoice;
                    });
                    print('AI Voice selected: ${aiVoice.name} (${aiVoice.character})');
                  },
                  onPollCreated: (poll) {
                    print('Timeline: Received poll callback: ${poll.question}');
                    setState(() {
                      _selectedPoll = poll;
                    });
                    print('Timeline: Poll set in state: ${_selectedPoll?.question}');
                  },
                  onMentionTapped: () {
                    setState(() {
                      _mentionModeEnabled = true;
                    });
                    // テキストフィールドにフォーカスを移動し、@を挿入
                    FocusScope.of(context).requestFocus(FocusNode());
                    final currentText = _postController.text;
                    final cursorPos = _postController.selection.baseOffset;
                    if (cursorPos >= 0) {
                      final newText = currentText.substring(0, cursorPos) + '@' + currentText.substring(cursorPos);
                      _postController.text = newText;
                      _postController.selection = TextSelection.fromPosition(
                        TextPosition(offset: cursorPos + 1),
                      );
                    } else {
                      _postController.text = currentText + '@';
                      _postController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _postController.text.length),
                      );
                    }
                  },
                  onLocationSelected: (address) {
                    // 投稿文に現在地の住所を挿入
                    final currentText = _postController.text;
                    final locationText = '📍 $address';
                    
                    // カーソル位置に挿入、またはテキストの最後に追加
                    final selection = _postController.selection;
                    if (selection.isValid) {
                      final beforeCursor = currentText.substring(0, selection.start);
                      final afterCursor = currentText.substring(selection.end);
                      _postController.text = beforeCursor + locationText + afterCursor;
                      _postController.selection = TextSelection.fromPosition(
                        TextPosition(offset: selection.start + locationText.length),
                      );
                    } else {
                      // カーソル位置が無効な場合、最後に追加
                      _postController.text = currentText.isEmpty 
                          ? locationText 
                          : '$currentText $locationText';
                      _postController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _postController.text.length),
                      );
                    }
                    
                    print('Location added to post: $address');
                  },
                  onRecruitmentModeToggled: () {
                    // 投稿文の最初に #募集 を挿入
                    const recruitmentTag = '#募集 ';
                    final currentText = _postController.text;
                    
                    if (!currentText.startsWith(recruitmentTag)) {
                      _postController.text = recruitmentTag + currentText;
                      _postController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _postController.text.length),
                      );
                    }
                    
                    setState(() {
                      _isRecruitmentMode = true;
                    });
                    
                    print('Recruitment tag added to post');
                  },
                  onEventCreated: (event) {
                    // イベント作成後に投稿として追加
                    final eventPost = Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      authorName: 'ユーザー',
                      authorBadge: '',
                      authorBadgeIds: ['verified_user'],
                      avatarUrl: 'https://placehold.co/32x32',
                      content: 'イベントを作成しました: ${event.title}',
                      timestamp: DateTime.now(),
                      likeCount: 0,
                      commentCount: 0,
                      type: PostType.event,
                      event: event,
                    );
                    
                    setState(() {
                      _followingPosts.insert(0, eventPost);
                    });
                    
                    print('Event posted: ${event.title}');
                    
                    // 確認メッセージ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('イベントを作成し、投稿しました'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              if (_isCameraMenuExpanded)
                InlineCameraMenu(
                  isExpanded: _isCameraMenuExpanded,
                  onToggle: () {
                    setState(() {
                      _isCameraMenuExpanded = false;
                    });
                  },
                  onPhotoSelected: (index, color) {
                    // 写真が選択されたときの処理
                    print('Timeline: Photo $index selected');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoEditScreen(
                          photoIndex: index,
                          photoColor: color,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
      // グローバルオプションオーバーレイ
      if (_showOptionsOverlay && _overlayPosition != null && _selectedPostId != null)
        Positioned(
          left: _overlayPosition!.dx,
          top: _overlayPosition!.dy,
          child: PostOptionsOverlay(
            authorName: _currentPosts.firstWhere((p) => p.id == _selectedPostId).authorName,
            onDismiss: _hideOptionsMenu,
            onOptionSelected: _handleOptionAction,
          ),
        ),
      ],
    ),
    // 不要なFloatingActionButtonを削除（要求仕様により）
    // floatingActionButton: null,
    );
  }

  bool _isRecruitmentPost(String content) {
    return content.startsWith('#募集');
  }

  void _submitPost() {
    if (_postController.text.isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null) {
      // 投稿文に#募集が含まれているかで募集投稿を判定
      final isRecruitment = _isRecruitmentPost(_postController.text);
      
      // Create new post
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'ユーザー',
        authorBadge: '',
        authorBadgeIds: ['rookie_reviewer'],
        avatarUrl: 'https://placehold.co/32x32',
        content: _postController.text.isEmpty ? '' : _postController.text,
        imageUrl: _selectedImage?.path,
        timestamp: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        bgm: _selectedBgm,
        aiVoice: _selectedAiVoice,
        poll: _selectedPoll,
        type: isRecruitment ? PostType.recruitment : PostType.normal,
      );
      
      print('Timeline: Creating post with BGM: ${_selectedBgm?.title ?? "None"}');
      print('Timeline: Creating post with AI Voice: ${_selectedAiVoice?.name ?? "None"}');
      print('Timeline: Creating post with Poll: ${_selectedPoll?.question ?? "None"}');
      
      setState(() {
        _followingPosts.insert(0, newPost);
        _postController.clear();
        _selectedImage = null;
        _selectedBgm = null; // 投稿後はBGMをクリア
        _selectedAiVoice = null; // 投稿後はAI音声をクリア
        _selectedPoll = null; // 投稿後はアンケートをクリア
        _isRecruitmentMode = false; // 投稿後は募集モードを解除
      });
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  void _showPhotoPickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoPickerModal(
        onImageSelected: (File image) {
          setState(() {
            _selectedImage = image;
          });
        },
      ),
    );
  }

}