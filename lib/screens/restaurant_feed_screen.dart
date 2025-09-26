import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/photo_picker_modal.dart';
import '../widgets/inline_plus_menu.dart';
import '../widgets/inline_camera_menu.dart';
import '../widgets/post_card_simple.dart';
import '../widgets/restaurant_detail_overlay.dart';
import '../screens/photo_edit_screen.dart';
import '../models/bgm.dart';
import '../models/ai_voice.dart';
import '../models/post.dart';
import '../models/restaurant.dart';
import '../models/rating_input.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../widgets/mention_input_widget.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../widgets/rating_input_widget.dart';
import '../widgets/restaurant_search_widget.dart';
import '../screens/user_profile_screen.dart';
import '../services/user_interest_service.dart';

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
  AiVoice? _selectedAiVoice;
  Poll? _selectedPoll;
  bool _isPlusMenuExpanded = false;
  bool _isCameraMenuExpanded = false;
  String? _selectedCategory;
  bool _showRestaurantOverlay = false;
  Restaurant? _selectedRestaurant;
  bool _isRecruitmentMode = false;
  bool _showReviewTools = false;
  RatingInput _ratingInput = RatingInput();
  bool _mentionModeEnabled = false;
  MentionInputWidget? _mentionWidget;
  
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
    User(
      id: '4',
      username: 'takeshi_ramen',
      displayName: 'タケシ',
      avatarUrl: 'https://placehold.co/32x32',
      badge: 'ラーメン通',
      badgeIds: ['ramen_expert'],
      isOnline: false,
    ),
    User(
      id: '5',
      username: 'emma_sweets',
      displayName: 'エマ',
      avatarUrl: 'https://placehold.co/32x32',
      badge: 'スイーツ専門家',
      badgeIds: ['sweet_lover'],
      isOnline: true,
    ),
  ];
  
  // フォロー中のユーザーからの投稿
  List<Post> _followingPosts = [
    Post(
      id: 'follow_post1',
      authorName: 'ユキ',
      authorBadge: 'フードブロガー',
      authorBadgeIds: ['food_photographer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: 'フォロー中の私が投稿したレビューです！新しいカフェで素敵な時間を過ごしました☕',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      likeCount: 12,
      commentCount: 3,
      restaurant: Restaurant(
        id: 'follow_rest1',
        name: 'コーヒー＆ブックス',
        category: 'カフェ',
        overallRating: 4.3,
        address: '東京都渋谷区表参道1-1-1',
        phoneNumber: '03-1111-2222',
        openingHours: '08:00-22:00',
        images: ['https://placehold.co/300x200'],
        description: '本に囲まれた静かなカフェ空間',
        reviewCount: 45,
        distance: 0.5,
        priceRange: '¥¥',
        latitude: 35.6658,
        longitude: 139.7098,
      ),
      rating: Rating(
        overall: 4.3,
        food: 4.0,
        service: 4.5,
        value: 4.5,
      ),
    ),
    Post(
      id: 'follow_post2',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      authorBadgeIds: ['master_reviewer', 'gourmet_explorer'],
      avatarUrl: 'https://placehold.co/32x32',
      content: 'フォロー中のダニエルです！最高のイタリアンレストランを発見！パスタが絶品でした🍝',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likeCount: 21,
      commentCount: 4,
      restaurant: Restaurant(
        id: 'follow_rest2',
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
  ];

  // おすすめ投稿（For You）
  List<Post> _recommendedPosts = [
    Post(
      id: 'post1',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      authorBadgeIds: ['master_reviewer', 'gourmet_explorer'],
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
      authorBadgeIds: ['master_reviewer'],
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
      authorBadgeIds: ['gourmet_explorer'],
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
      authorBadgeIds: ['food_photographer'],
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
      authorBadgeIds: ['middle_reviewer'],
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
    List<Post> basePosts = isFollowingTab ? _followingPosts : _recommendedPosts;
    
    if (_selectedCategory == null) {
      return basePosts;
    }
    
    final postIds = _categoryPostMapping[_selectedCategory] ?? [];
    return basePosts.where((post) => postIds.contains(post.id)).toList();
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
                  // Tab bar with icons
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
          // カテゴリタブ
          _buildCategoryTabs(),
          // Posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              itemCount: UserInterestService.filterPosts(_filteredPosts).length,
              itemBuilder: (context, index) {
                // 興味がない投稿をフィルタリングした後の投稿を取得
                final interestFilteredPosts = UserInterestService.filterPosts(_filteredPosts);
                final post = interestFilteredPosts[index];
                
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: PostCardSimple(
                    post: post,
                    onLike: () {
                      setState(() {
                        // フォロー中の投稿かおすすめ投稿かを判定して更新
                        final followingIndex = _followingPosts.indexWhere((p) => p.id == post.id);
                        final recommendedIndex = _recommendedPosts.indexWhere((p) => p.id == post.id);
                        
                        if (followingIndex != -1) {
                          _followingPosts[followingIndex] = post.copyWith(
                            isLiked: !post.isLiked,
                            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                          );
                        } else if (recommendedIndex != -1) {
                          _recommendedPosts[recommendedIndex] = post.copyWith(
                            isLiked: !post.isLiked,
                            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                          );
                        }
                      });
                    },
                    onPostUpdated: (updatedPost) {
                      setState(() {
                        final followingIndex = _followingPosts.indexWhere((p) => p.id == post.id);
                        final recommendedIndex = _recommendedPosts.indexWhere((p) => p.id == post.id);
                        
                        if (followingIndex != -1) {
                          _followingPosts[followingIndex] = updatedPost;
                        } else if (recommendedIndex != -1) {
                          _recommendedPosts[recommendedIndex] = updatedPost;
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
                        final followingIndex = _followingPosts.indexWhere((p) => p.id == post.id);
                        final recommendedIndex = _recommendedPosts.indexWhere((p) => p.id == post.id);
                        final updatedPost = post.copyWith(isSaved: !post.isSaved);
                        
                        if (followingIndex != -1) {
                          _followingPosts[followingIndex] = updatedPost;
                        } else if (recommendedIndex != -1) {
                          _recommendedPosts[recommendedIndex] = updatedPost;
                          
                          // プロフィール画面の保存リストを更新
                          if (updatedPost.isSaved) {
                            UserProfileScreen.savePost(updatedPost);
                          } else {
                            UserProfileScreen.unsavePost(updatedPost);
                          }
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
                  onAiVoiceSelected: (aiVoice) {
                    setState(() {
                      _selectedAiVoice = aiVoice;
                    });
                    print('AI Voice selected: ${aiVoice.name} (${aiVoice.character})');
                  },
                  onPollCreated: (poll) {
                    print('RestaurantFeed: Received poll callback: ${poll.question}');
                    setState(() {
                      _selectedPoll = poll;
                    });
                    print('RestaurantFeed: Poll set in state: ${_selectedPoll?.question}');
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
                      authorName: 'あなた',
                      authorBadge: 'ユーザー',
                      authorBadgeIds: ['rookie_reviewer'],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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

        // AI Voice display area (if AI voice is selected)
        if (_selectedAiVoice != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: (_selectedBgm == null && _selectedPoll == null) ? BorderSide(
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
              child: Stack(
                children: [
                  TextField(
                    controller: _postController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: true,
                    autocorrect: true,
                    onTap: () {
                      setState(() {
                        _showReviewTools = true;
                      });
                    },
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
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null || _selectedImage != null) {
                        _submitPost();
                      }
                    },
                  ),
                  // メンション機能
                  if (_mentionModeEnabled)
                    MentionInputWidget(
                      controller: _postController,
                      followers: _followers,
                      onUserMentioned: (user) {
                        print('User mentioned: ${user.username}');
                        // メンションが完了したらモードを無効化
                        setState(() {
                          _mentionModeEnabled = false;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          // Send button
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: GestureDetector(
              onTap: (_postController.text.trim().isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null || _selectedImage != null) ? () {
                print('RestaurantFeed: Send button tapped');
                _submitPost();
              } : null,
              child: Container(
                width: AppDimensions.iconLargeSize,
                height: AppDimensions.iconLargeSize,
                child: Icon(
                  Icons.send,
                  size: 20,
                  color: (_postController.text.trim().isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null || _selectedImage != null)
                      ? Colors.black 
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
        ),
        // Review tools (星評価と店舗情報) - Slack風に展開
        if (_showReviewTools)
          _buildReviewTools(),
      ],
    );
  }

  Widget _buildReviewTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          // 星評価アイコン
          GestureDetector(
            onTap: _showRatingInput,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _ratingInput.hasAnyRating ? Colors.amber[100] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _ratingInput.hasAnyRating ? Colors.amber : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: _ratingInput.hasAnyRating ? Colors.amber : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _ratingInput.hasAnyRating ? '評価済み' : '評価',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _ratingInput.hasAnyRating ? Colors.amber[800] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 店舗情報アイコン
          GestureDetector(
            onTap: _showRestaurantSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedRestaurant != null ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedRestaurant != null ? Colors.blue : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 20,
                    color: _selectedRestaurant != null ? Colors.blue : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedRestaurant != null ? _selectedRestaurant!.name : '店舗',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedRestaurant != null ? Colors.blue[800] : Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 閉じるボタン
          GestureDetector(
            onTap: () {
              setState(() {
                _showReviewTools = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isRecruitmentPost(String content) {
    return content.startsWith('#募集');
  }

  void _submitPost() {
    print('RestaurantFeed: _submitPost called with text: "${_postController.text.trim()}"');
    
    if (_postController.text.trim().isNotEmpty || _selectedPoll != null || _selectedBgm != null || _selectedAiVoice != null || _selectedImage != null) {
      // 投稿文に#募集が含まれているかで募集投稿を判定
      final isRecruitment = _isRecruitmentPost(_postController.text.trim());
      
      // 評価があればRatingオブジェクトを作成
      Rating? postRating;
      if (_ratingInput.hasAnyRating) {
        postRating = Rating(
          overall: _ratingInput.overall,
          food: _ratingInput.food,
          service: _ratingInput.service,
          value: _ratingInput.value,
        );
      }

      // Create new Post object
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'あなた',
        authorBadge: 'ユーザー',
        authorBadgeIds: ['rookie_reviewer'],
        avatarUrl: 'https://placehold.co/32x32',
        content: _postController.text.trim().isEmpty ? '' : _postController.text.trim(),
        imageUrl: _selectedImage?.path,
        timestamp: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        bgm: _selectedBgm,
        aiVoice: _selectedAiVoice,
        poll: _selectedPoll,
        restaurant: _selectedRestaurant,
        rating: postRating,
        type: isRecruitment ? PostType.recruitment : PostType.normal,
      );
      
      print('RestaurantFeed: Creating new post with ID: ${newPost.id}');
      print('RestaurantFeed: Current following posts count before insert: ${_followingPosts.length}');
      
      setState(() {
        _followingPosts.insert(0, newPost);
        _postController.clear();
        _selectedImage = null;
        _selectedBgm = null;
        _selectedAiVoice = null;
        _selectedPoll = null;
        _selectedRestaurant = null;
        _ratingInput = RatingInput();
        _isPlusMenuExpanded = false;
        _isCameraMenuExpanded = false;
        _isRecruitmentMode = false; // 投稿後は募集モードを解除
        _showReviewTools = false; // レビューツールを閉じる
      });
      
      print('RestaurantFeed: Following posts count after insert: ${_followingPosts.length}');
      
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

  void _showRatingInput() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: RatingInputWidget(
          rating: _ratingInput,
          onRatingChanged: (rating) {
            setState(() {
              _ratingInput = rating;
            });
          },
        ),
      ),
    );
  }

  void _showRestaurantSearch() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: RestaurantSearchWidget(
          onRestaurantSelected: (restaurant) {
            setState(() {
              _selectedRestaurant = restaurant;
            });
          },
        ),
      ),
    );
  }

}