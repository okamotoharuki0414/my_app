import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
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

  final List<Post> _posts = [
    Post(
      id: '1',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post.\nbrah brah brah',
      timestamp: DateTime(2024, 5, 11, 12, 0),
      likeCount: 21,
      commentCount: 4,
    ),
    Post(
      id: '2',
      authorName: 'ダニエル',
      authorBadge: 'トップレビュワー',
      avatarUrl: 'https://placehold.co/32x32',
      content: 'Body text for a post. Since it\'s a social app, sometimes it\'s a hot take, and sometimes it\'s a question.',
      timestamp: DateTime(2024, 5, 11, 12, 0),
      likeCount: 21,
      commentCount: 4,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
                                        color: AppColors.primary,
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
                                        color: AppColors.primary,
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
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingMedium,
              ),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  onLike: () {
                    setState(() {
                      _posts[index] = post.copyWith(
                        isLiked: !post.isLiked,
                        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
                      );
                    });
                  },
                  onComment: () {
                    // Handle comment action
                  },
                  onShare: () {
                    // Handle share action
                  },
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
                  child: Container(
                    width: AppDimensions.iconContainerSize,
                    height: AppDimensions.iconContainerSize,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // Attachment button
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  child: Container(
                    width: AppDimensions.sectionSpacing,
                    height: AppDimensions.sectionSpacing,
                    child: const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: AppColors.textSecondary,
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
                    ),
                  ),
                ),
                // Send button
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Container(
                    width: AppDimensions.iconLargeSize,
                    height: AppDimensions.iconLargeSize,
                    child: const Icon(
                      Icons.send,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom navigation
          Container(
            height: AppDimensions.bottomNavHeight,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.borderLight,
                  width: AppDimensions.borderThin,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Navigation buttons
                  Container(
                    height: 74,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXXLarge,
                      vertical: AppDimensions.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavButton(Icons.home, true),
                        _buildNavButton(Icons.search, false),
                        _buildNavButton(Icons.add_circle_outline, false),
                        _buildNavButton(Icons.person_outline, false),
                      ],
                    ),
                  ),
                  // Home indicator
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
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

  Widget _buildNavButton(IconData icon, bool isActive) {
    return Container(
      width: 76,
      height: 49,
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: AppDimensions.iconLargeSize,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}