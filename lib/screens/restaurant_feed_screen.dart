import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/photo_picker_modal.dart';
import '../widgets/inline_plus_menu.dart';
import '../widgets/inline_camera_menu.dart';
import '../widgets/post_card.dart';
import '../widgets/restaurant_detail_overlay.dart';
import '../screens/photo_edit_screen.dart';
import '../models/bgm.dart';
import '../models/post.dart';
import '../models/restaurant.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class RestaurantFeedScreen extends StatefulWidget {
  const RestaurantFeedScreen({super.key});

  @override
  State<RestaurantFeedScreen> createState() => _RestaurantFeedScreenState();
}

class _RestaurantFeedScreenState extends State<RestaurantFeedScreen> {
  bool isFollowingTab = true;
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;
  Bgm? _selectedBgm;
  bool _isPlusMenuExpanded = false;
  bool _isCameraMenuExpanded = false;
  String? _selectedCategory;
  bool _showRestaurantOverlay = false;
  Restaurant? _selectedRestaurant;
  
  // カテゴリリスト（使用頻度順）
  final List<String> _categories = [
    'レストラン',
    'カフェ',
    'ラーメン',
    '日本料理',
    'イタリアン',
    '居酒屋',
    'ファストフード',
    'アジアン',
    '中華料理',
    'うどん・そば',
    '洋食',
    'フレンチ',
    'バー',
    '海鮮',
    '焼肉',
    'すし',
    '韓国料理',
    'タイ料理',
    'インド料理',
    'メキシコ料理',
    'スイーツ',
    'パン・ベーカリー',
    'ピザ',
    'ハンバーガー',
    '弁当・惣菜',
    '定食・食堂',
    '鍋料理',
    'お好み焼き',
    'たこ焼き',
    '天ぷら',
    'とんかつ',
    'カレー',
    'パスタ',
    'ステーキ',
    'しゃぶしゃぶ',
    '串カツ',
    'もんじゃ焼き',
    'ビュッフェ',
    'テイクアウト',
    'デリバリー',
    'ブランチ',
    'ディナー',
    'ランチ',
    'モーニング',
  ];
  
  // List of review posts as Post objects
  List<Post> _allPosts = [
    Post(
      id: 'post1',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: '最高のイタリアンレストランを発見！パスタが絶品でした🍝',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likeCount: 21,
      commentCount: 4,
      restaurant: Restaurant(
        id: 'rest1',
        name: 'リストランテ ベッラヴィスタ',
        category: 'イタリアン',
        overallRating: 4.5,
        address: '東京都渋谷区神宮前1-2-3',
        phoneNumber: '03-1234-5678',
        openingHours: '11:30-14:30, 18:00-22:00',
        images: ['https://placehold.co/300x200'],
        description: '本格的なイタリア料理を楽しめる高級レストランです。',
        reviewCount: 128,
        distance: 0.8,
        priceRange: '¥¥¥',
        latitude: 35.6762,
        longitude: 139.6503,
      ),
      rating: Rating(
        overall: 4.5,
        food: 4.8,
        service: 4.2,
        value: 4.0,
      ),
    ),
    Post(
      id: 'post2',
      authorName: 'エレナ',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: '老舗の日本料理店で最高の懐石料理を堪能しました。',
      imageUrl: 'https://placehold.co/287x219',
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      likeCount: 21,
      commentCount: 2,
      restaurant: Restaurant(
        id: 'rest2',
        name: '懐石料理 山田',
        category: '日本料理',
        overallRating: 4.8,
        address: '東京都新宿区歌舞伎町2-1-5',
        phoneNumber: '03-5678-9012',
        openingHours: '17:00-23:00 (日曜定休)',
        images: ['https://placehold.co/300x200'],
        description: '伝統的な日本料理を現代風にアレンジした懐石料理店です。',
        reviewCount: 95,
        distance: 1.2,
        priceRange: '¥¥¥¥',
        latitude: 35.6719,
        longitude: 139.7655,
      ),
      rating: Rating(
        overall: 4.8,
        food: 5.0,
        service: 4.5,
        value: 4.5,
      ),
    ),
    Post(
      id: 'post3',
      authorName: 'タカシ',
      authorBadge: 'グルメ',
      avatarUrl: 'https://placehold.co/32x32',
      content: '新宿の隠れ家カフェ☕ 静かで作業に最適な場所です。',
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      likeCount: 15,
      commentCount: 3,
      restaurant: Restaurant(
        id: 'rest3',
        name: 'カフィ アオゾラ',
        category: 'カフェ',
        overallRating: 4.2,
        address: '東京都新宿区新宿3-15-8',
        phoneNumber: '03-2345-6789',
        openingHours: '8:00-20:00',
        images: ['https://placehold.co/300x200'],
        description: '落ち着いた雰囲気で仕事や勉強に集中できるカフェです。',
        reviewCount: 67,
        distance: 2.1,
        priceRange: '¥¥',
        latitude: 35.6896,
        longitude: 139.7006,
      ),
      rating: Rating(
        overall: 4.2,
        service: 4.5,
        value: 4.8,
      ),
    ),
    Post(
      id: 'post4',
      authorName: 'ユキ',
      authorBadge: 'フードブロガー',
      avatarUrl: 'https://placehold.co/32x32',
      content: '博多ラーメン🍜 濃厚な豚骨スープが最高においしい！',
      imageUrl: 'https://placehold.co/287x219',
      timestamp: DateTime.now().subtract(Duration(hours: 8)),
      likeCount: 32,
      commentCount: 7,
      restaurant: Restaurant(
        id: 'rest4',
        name: '博多一風堂',
        category: 'ラーメン',
        overallRating: 4.6,
        address: '福岡県福岡市博多区中洲川端町5-7-1',
        phoneNumber: '092-1234-5678',
        openingHours: '11:00-15:00, 18:00-23:00',
        images: ['https://placehold.co/300x200'],
        description: '本場博多ラーメンの老舗。濃厚な豚骨スープが自慢です。',
        reviewCount: 203,
        distance: 3.5,
        priceRange: '¥',
        latitude: 35.7148,
        longitude: 139.7967,
      ),
      rating: Rating(
        overall: 4.6,
        food: 4.9,
        service: 4.2,
        value: 4.7,
      ),
    ),
    Post(
      id: 'post5',
      authorName: 'アヤカ',
      authorBadge: 'レビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: '渋谷のフレンチビストロ。ワインの品揃えが素晴らしい🍷',
      timestamp: DateTime.now().subtract(Duration(hours: 10)),
      likeCount: 28,
      commentCount: 5,
      restaurant: Restaurant(
        id: 'rest5',
        name: 'ビストロ ラ ヴィーニュ',
        category: 'フレンチ',
        overallRating: 4.4,
        address: '東京都渋谷区渋谷2-8-12',
        phoneNumber: '03-3456-7890',
        openingHours: '18:00-24:00 (月曜定休)',
        images: ['https://placehold.co/300x200'],
        description: '気軽に楽しめるフレンチビストロ。ワインのセレクションが豊富です。',
        reviewCount: 156,
        distance: 1.8,
        priceRange: '¥¥¥',
        latitude: 35.6586,
        longitude: 139.7016,
      ),
      rating: Rating(
        overall: 4.4,
        food: 4.3,
        service: 4.6,
      ),
    ),
  ];
  
  // カテゴリと投稿のマッピング
  final Map<String, List<String>> _categoryPostMapping = {
    'イタリアン': ['post1'],
    '日本料理': ['post2'],
    'カフェ': ['post3'],
    'ラーメン': ['post4'],
    'フレンチ': ['post5'],
    'レストラン': ['post1', 'post2', 'post5'],
    '居酒屋': ['post2'],
    'ファストフード': [],
    'アジアン': ['post4'],
    '中華料理': [],
    'うどん・そば': [],
    '洋食': ['post1', 'post5'],
    'バー': [],
    '海鮮': ['post2'],
    '焼肉': [],
    'すし': [],
    '韓国料理': [],
    'タイ料理': [],
    'インド料理': [],
    'メキシコ料理': [],
    'スイーツ': ['post3'],
    'パン・ベーカリー': ['post3'],
    'ピザ': ['post1'],
    'ハンバーガー': [],
    '弁当・惣菜': [],
    '定食・食堂': [],
    '鍋料理': [],
    'お好み焼き': [],
    'たこ焼き': [],
    '天ぷら': ['post2'],
    'とんかつ': [],
    'カレー': [],
    'パスタ': ['post1'],
    'ステーキ': [],
    'しゃぶしゃぶ': [],
    '串カツ': [],
    'もんじゃ焼き': [],
    'ビュッフェ': [],
    'テイクアウト': [],
    'デリバリー': [],
    'ブランチ': ['post3', 'post5'],
    'ディナー': ['post1', 'post5'],
    'ランチ': ['post2', 'post3'],
    'モーニング': ['post3'],
  };
  
  List<Post> get _filteredPosts {
    if (_selectedCategory == null) {
      return _allPosts;
    }
    
    final postIds = _categoryPostMapping[_selectedCategory] ?? [];
    return _allPosts.where((post) => postIds.contains(post.id)).toList();
  }


  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
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
          // カテゴリタブ
          _buildCategoryTabs(),
          // Posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                final post = _filteredPosts[index];
                
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: PostCard(
                    post: post,
                    onShowOptionsMenu: (context, postId) {
                      // Handle options menu
                    },
                    onRestaurantTap: (restaurant) {
                      setState(() {
                        _selectedRestaurant = restaurant;
                        _showRestaurantOverlay = true;
                      });
                    },
                    onLike: () {
                      setState(() {
                        final postIndex = _allPosts.indexWhere((p) => p.id == post.id);
                        if (postIndex != -1) {
                          _allPosts[postIndex] = post.copyWith(
                            isLiked: !post.isLiked,
                            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                          );
                        }
                      });
                    },
                    onPostUpdated: (updatedPost) {
                      setState(() {
                        final postIndex = _allPosts.indexWhere((p) => p.id == post.id);
                        if (postIndex != -1) {
                          _allPosts[postIndex] = updatedPost;
                        }
                      });
                    },
                    onSave: () {
                      setState(() {
                        final postIndex = _allPosts.indexWhere((p) => p.id == post.id);
                        if (postIndex != -1) {
                          _allPosts[postIndex] = post.copyWith(isSaved: !post.isSaved);
                        }
                      });
                    },
                    onMore: () {
                      // Handle more action
                    },
                  ),
                );
              },
            ),
          ),
          // Post input area
          _buildPostInput(),
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
                    print('RestaurantFeed: Photo $index selected');
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
          // Restaurant detail overlay
          if (_showRestaurantOverlay && _selectedRestaurant != null)
            RestaurantDetailOverlay(
              restaurant: _selectedRestaurant!,
              onClose: () {
                setState(() {
                  _showRestaurantOverlay = false;
                  _selectedRestaurant = null;
                });
              },
            ),
        ],
      ),
    );
  }





  Widget _buildPostInput() {
    return Container(
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
          // Avatar (Plus button)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: GestureDetector(
              onTap: () {
                print('RestaurantFeed: Plus button tapped');
                setState(() {
                  _isPlusMenuExpanded = !_isPlusMenuExpanded;
                  print('RestaurantFeed: _isPlusMenuExpanded set to $_isPlusMenuExpanded');
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
                print('RestaurantFeed: Camera button tapped');
                setState(() {
                  _isCameraMenuExpanded = !_isCameraMenuExpanded;
                  print('RestaurantFeed: _isCameraMenuExpanded set to $_isCameraMenuExpanded');
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
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _submitPost();
                  }
                },
              ),
            ),
          ),
          // Send button
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: GestureDetector(
              onTap: _postController.text.trim().isNotEmpty ? () {
                print('RestaurantFeed: Send button tapped');
                _submitPost();
              } : null,
              child: Container(
                width: AppDimensions.iconLargeSize,
                height: AppDimensions.iconLargeSize,
                child: Icon(
                  Icons.send,
                  size: 20,
                  color: _postController.text.trim().isNotEmpty 
                      ? Colors.black 
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitPost() {
    print('RestaurantFeed: _submitPost called with text: "${_postController.text.trim()}"');
    
    if (_postController.text.trim().isNotEmpty) {
      // Create new Post object
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'あなた',
        authorBadge: 'ユーザー',
        avatarUrl: 'https://placehold.co/32x32',
        content: _postController.text.trim(),
        imageUrl: _selectedImage?.path,
        timestamp: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        bgm: _selectedBgm,
      );
      
      print('RestaurantFeed: Creating new post with ID: ${newPost.id}');
      print('RestaurantFeed: Current posts count before insert: ${_allPosts.length}');
      
      setState(() {
        _allPosts.insert(0, newPost);
        _postController.clear();
        _selectedImage = null;
        _selectedBgm = null;
        _isPlusMenuExpanded = false;
        _isCameraMenuExpanded = false;
      });
      
      print('RestaurantFeed: Posts count after insert: ${_allPosts.length}');
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('レビューを投稿しました'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('RestaurantFeed: Post text is empty, not submitting');
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

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedCategory == category) {
                    // 同じカテゴリをタップしたら選択を解除
                    _selectedCategory = null;
                  } else {
                    _selectedCategory = category;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.0, // 行間を締めて中央対置を正確に
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}