import 'package:flutter/material.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/star_rating.dart';
import '../widgets/restaurant_info_tab.dart';
import '../widgets/user_badge_widget.dart';
import '../widgets/event_invitation_card.dart';
import '../widgets/hashtag_text.dart';
import '../widgets/poll_widget.dart';
import '../screens/google_maps_restaurant_detail_screen.dart';
import '../widgets/post_options_overlay.dart';
import '../services/user_interest_service.dart';
import '../screens/report_post_screen.dart';
import '../screens/block_user_screen.dart';
import '../screens/report_user_screen.dart';

class PostCardSimple extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final Function(Post)? onPostUpdated;

  const PostCardSimple({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onMore,
    this.onPostUpdated,
  });

  @override
  State<PostCardSimple> createState() => _PostCardSimpleState();
}

class _PostCardSimpleState extends State<PostCardSimple> {
  bool _showOptionsOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
      onTap: () {
        // 投稿カードタップ時に詳細画面に遷移
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              post: widget.post,
              onLike: widget.onLike,
              onShare: widget.onShare,
              onSave: widget.onSave,
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
                  Container(
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
                      ],
                    ),
                  ),
                  // More button
                  IconButton(
                    onPressed: () {
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
            
            // AI Voice (if exists)
            if (widget.post.aiVoice != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.aiVoice!.iconEmoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.aiVoice!.name} • ${widget.post.aiVoice!.character}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            
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
            
            // Action buttons
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
                  const SizedBox(width: AppDimensions.paddingLarge),
                  
                  // Comment button
                  GestureDetector(
                    onTap: widget.onComment,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
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
                  const SizedBox(width: AppDimensions.paddingLarge),
                  
                  // Share button
                  GestureDetector(
                    onTap: widget.onShare,
                    child: const Icon(
                      Icons.share,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingLarge),
                  
                  // Save button
                  GestureDetector(
                    onTap: widget.onSave,
                    child: Icon(
                      widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: widget.post.isSaved ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
        // オプションオーバーレイ
        if (_showOptionsOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showOptionsOverlay = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Stack(
                  children: [
                    Positioned(
                      top: 120, // ヘッダー下の位置
                      right: 20,
                      child: PostOptionsOverlay(
                        onDismiss: () {
                          setState(() {
                            _showOptionsOverlay = false;
                          });
                        },
                        authorName: widget.post.authorName,
                        onOptionSelected: (String action) async {
                          setState(() {
                            _showOptionsOverlay = false;
                          });
                          switch (action) {
                            case 'block_account':
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlockUserScreen(post: widget.post),
                                ),
                              );
                              break;
                            case 'report_post':
                              print('Report post: ${widget.post.id}');
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReportPostScreen(post: widget.post),
                                ),
                              );
                              break;
                            case 'hide_post':
                              print('Hide post: ${widget.post.id}');
                              break;
                            case 'not_interested':
                              print('Not interested: ${widget.post.id}');
                              await UserInterestService.markPostAsNotInterested(widget.post);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('この投稿に興味がないとマークしました。類似の投稿が表示されにくくなります。'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              break;
                            case 'report_account':
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReportUserScreen(post: widget.post),
                                ),
                              );
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}