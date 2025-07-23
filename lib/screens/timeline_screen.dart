import 'package:flutter/material.dart';
import 'dart:io';
import '../models/post.dart';
import '../models/comment.dart';
import '../widgets/post_card.dart';
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
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

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
  bool _isPlusMenuExpanded = false;
  bool _isCameraMenuExpanded = false;
  bool _showOptionsOverlay = false;
  String? _selectedPostId;
  Offset? _overlayPosition;

  final List<Post> _posts = [
    Post(
      id: '1',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post.\nbrah brah brah',
      timestamp: DateTime(2024, 5, 11, 12, 0),
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
      comments: [
        Comment(
          id: 'c1',
          authorName: 'エレナ',
          authorHandle: '@elena_foodie',
          authorBadge: 'グルメ',
          content: 'とても美味しそうですね！お店の場所を教えてください。',
          createdAt: DateTime(2024, 5, 11, 12, 15),
          likes: 3,
        ),
        Comment(
          id: 'c2',
          authorName: 'タカシ',
          authorHandle: '@takashi_eats',
          authorBadge: 'レビュワー',
          content: 'この料理、前に食べたことがあります。本当に絶品でした！',
          createdAt: DateTime(2024, 5, 11, 12, 30),
          likes: 1,
          isLiked: true,
        ),
        Comment(
          id: 'c3',
          authorName: 'ミユキ',
          authorHandle: '@miyuki_gourmet',
          authorBadge: 'フードブロガー',
          content: '写真だけでお腹が空いてきました😋',
          createdAt: DateTime(2024, 5, 11, 13, 0),
          likes: 5,
        ),
      ],
    ),
    Post(
      id: '2',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post. Since it\'s a social app, sometimes it\'s a hot take, and sometimes it\'s a question.',
      timestamp: DateTime(2024, 5, 11, 12, 0),
      likeCount: 21,
      commentCount: 2,
      comments: [
        Comment(
          id: 'c4',
          authorName: 'ユウタ',
          authorHandle: '@yuta_gourmet',
          authorBadge: 'レビュワー',
          content: '同感です！最近のトレンドについてどう思いますか？',
          createdAt: DateTime(2024, 5, 11, 12, 45),
          likes: 2,
        ),
        Comment(
          id: 'c5',
          authorName: 'アヤカ',
          authorHandle: '@ayaka_foodlover',
          authorBadge: 'ユーザー',
          content: '興味深い投稿ですね👍',
          createdAt: DateTime(2024, 5, 11, 13, 10),
          likes: 1,
        ),
      ],
    ),
    Post(
      id: '3',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post.\nbrah brah brah',
      imageUrl: 'https://placehold.co/287x219',
      timestamp: DateTime(2024, 5, 11, 12, 0),
      likeCount: 21,
      commentCount: 4,
    ),
    Post(
      id: '4',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post.\nbrah brah brah',
      timestamp: DateTime(2024, 5, 11, 12, 0),
      likeCount: 21,
      commentCount: 4,
    ),
  ];

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
    
    final postIndex = _posts.indexWhere((p) => p.id == _selectedPostId);
    if (postIndex == -1) return;
    
    final post = _posts[postIndex];
    
    switch (action) {
      case 'hide_post':
        setState(() {
          _posts[postIndex] = post.copyWith(isHidden: true);
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
                  // Tab bar
                  Container(
                    height: AppDimensions.tabBarHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXLarge,
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
                                    style: isFollowingTab
                                        ? AppTextStyles.tabActive
                                        : AppTextStyles.tabInactive,
                                  ),
                                  const SizedBox(height: AppDimensions.paddingSmall),
                                  if (isFollowingTab)
                                    Container(
                                      width: AppDimensions.iconLargeSize,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
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
                                    style: !isFollowingTab
                                        ? AppTextStyles.tabActive
                                        : AppTextStyles.tabInactive,
                                  ),
                                  const SizedBox(height: AppDimensions.paddingSmall),
                                  if (!isFollowingTab)
                                    Container(
                                      width: AppDimensions.iconLargeSize,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
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
              itemCount: _posts.where((post) => !post.isHidden).length,
              itemBuilder: (context, index) {
                final visiblePosts = _posts.where((post) => !post.isHidden).toList();
                final post = visiblePosts[index];
                return PostCard(
                  post: post,
                  onShowOptionsMenu: _showOptionsMenu,
                  onLike: () {
                    setState(() {
                      final originalIndex = _posts.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        _posts[originalIndex] = post.copyWith(
                          isLiked: !post.isLiked,
                          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                        );
                      }
                    });
                  },
                  // onComment: () {
                  //   // Handle comment action
                  // },
                  onPostUpdated: (updatedPost) {
                    setState(() {
                      final originalIndex = _posts.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        _posts[originalIndex] = updatedPost;
                      }
                    });
                  },
                  onSave: () {
                    setState(() {
                      final originalIndex = _posts.indexWhere((p) => p.id == post.id);
                      if (originalIndex != -1) {
                        _posts[originalIndex] = post.copyWith(isSaved: !post.isSaved);
                      }
                    });
                    print('Post ${post.id} saved: ${!post.isSaved}');
                  },
                  // onShare: () {
                  //   // Handle share action
                  // },
                  onMore: () {
                    // Handle more action
                  },
                );
              },
            ),
          ),
          // Post input area
          Container(
            height: AppDimensions.bottomInputHeight,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: AppDimensions.borderRegular,
                ),
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
                      decoration: const InputDecoration(
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
                    onTap: _postController.text.isNotEmpty ? () {
                      // Handle post submission
                      _submitPost();
                    } : null,
                    child: Container(
                      width: AppDimensions.iconLargeSize,
                      height: AppDimensions.iconLargeSize,
                      child: Icon(
                        Icons.send,
                        size: 20,
                        color: _postController.text.isNotEmpty 
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
            authorName: _posts.firstWhere((p) => p.id == _selectedPostId).authorName,
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

  void _submitPost() {
    if (_postController.text.isNotEmpty) {
      // Create new post
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'ユーザー',
        authorBadge: '',
        avatarUrl: 'https://placehold.co/32x32',
        content: _postController.text,
        imageUrl: _selectedImage?.path,
        timestamp: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
      );
      
      setState(() {
        _posts.insert(0, newPost);
        _postController.clear();
        _selectedImage = null;
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