import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/event.dart';
import '../widgets/event_invitation_card.dart';
import '../widgets/user_badge_widget.dart';
import '../screens/event_detail_screen.dart';

class EventPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final Function(Post)? onPostUpdated;

  const EventPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
    this.onMore,
    this.onPostUpdated,
  });

  @override
  State<EventPostCard> createState() => _EventPostCardState();
}

class _EventPostCardState extends State<EventPostCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (widget.post.content.isNotEmpty) _buildContent(),
          _buildEventCard(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.post.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.authorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.post.authorBadgeIds.isNotEmpty)
                      UserBadgeWidget(
                        badgeIds: widget.post.authorBadgeIds,
                        maxDisplay: 1,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'イベントを作成しました',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.post.formattedTimestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onMore,
            icon: Icon(
              Icons.more_horiz,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    if (widget.post.event == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              event: widget.post.event!,
              currentUserStatus: null, // ユーザーの参加状況
            ),
          ),
        );
      },
      child: EventInvitationCard(
        event: widget.post.event!,
        currentUserStatus: null,
        onAccept: () => _handleEventAction(InvitationStatus.accepted),
        onDecline: () => _handleEventAction(InvitationStatus.declined),
        onMaybe: () => _handleEventAction(InvitationStatus.maybe),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildActionButton(
            icon: widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: widget.post.isLiked ? Colors.red : Colors.grey[600]!,
            count: widget.post.likeCount,
            onTap: widget.onLike,
          ),
          const SizedBox(width: 24),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.grey[600]!,
            count: widget.post.commentCount,
            onTap: () {
              // コメント機能（実装済み）
            },
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onSave,
            icon: Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: widget.post.isSaved ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleEventAction(InvitationStatus status) {
    String message;
    switch (status) {
      case InvitationStatus.accepted:
        message = 'イベント「${widget.post.event!.title}」への参加を承諾しました！';
        break;
      case InvitationStatus.declined:
        message = 'イベント「${widget.post.event!.title}」への参加を辞退しました。';
        break;
      case InvitationStatus.maybe:
        message = 'イベント「${widget.post.event!.title}」を検討中にしました。';
        break;
      case InvitationStatus.pending:
        message = 'ステータスを更新しました。';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}