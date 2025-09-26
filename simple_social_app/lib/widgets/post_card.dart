import 'package:flutter/material.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.postCardWidth,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.borderThin,
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
                      post.avatarUrl,
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
                        post.formattedTimestamp,
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
                            post.authorName,
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Text(
                            post.authorBadge,
                            style: AppTextStyles.badge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More button
                if (post.hasMoreActions)
                  IconButton(
                    onPressed: onMore,
                    icon: const Icon(Icons.more_horiz),
                    iconSize: AppDimensions.iconLargeSize,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Text(
              post.content,
              style: AppTextStyles.body,
            ),
          ),
          // Image (if exists)
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingLarge,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                child: Image.network(
                  post.imageUrl!,
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
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Container(
                        width: AppDimensions.iconSize,
                        height: AppDimensions.iconSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimensions.borderRegular,
                          ),
                        ),
                        child: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: post.isLiked ? Colors.red : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        '${post.likeCount}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // Comment button
                GestureDetector(
                  onTap: onComment,
                  child: Row(
                    children: [
                      SizedBox(
                        width: AppDimensions.iconSize,
                        height: AppDimensions.iconSize,
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        '${post.commentCount}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                // Share button
                GestureDetector(
                  onTap: onShare,
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
                // Additional action buttons
                SizedBox(
                  width: AppDimensions.iconSize,
                  height: AppDimensions.iconSize,
                  child: Icon(
                    Icons.bookmark_border,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.sectionSpacing),
                SizedBox(
                  width: AppDimensions.iconSize,
                  height: AppDimensions.iconSize,
                  child: Icon(
                    Icons.download,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}