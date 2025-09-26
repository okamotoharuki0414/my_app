import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../constants/app_colors.dart';
import '../constants/app_ikyu_styles.dart';
import '../constants/app_dimensions.dart';
import '../widgets/star_rating.dart';
import '../widgets/restaurant_info_tab.dart';
import '../screens/google_maps_restaurant_detail_screen.dart';

/// Twitter風の投稿詳細画面
/// 投稿カードをタップした時に表示される詳細画面
class PostDetailScreen extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.onLike,
    this.onShare,
    this.onSave,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  List<Comment> _comments = [];
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _comments = List.from(widget.post.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'あなた',
      authorHandle: '@you',
      authorBadge: 'ユーザー',
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      likes: 0,
    );

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '投稿',
          style: AppIkyuStyles.dishName,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: widget.onShare,
          ),
        ],
      ),
      body: Column(
        children: [
          // メイン投稿コンテンツ
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 投稿ヘッダー
                  _buildPostHeader(),
                  
                  // 投稿コンテンツ
                  _buildPostContent(),
                  
                  // 全星評価表示
                  if (widget.post.rating != null && widget.post.rating!.hasAnyRating)
                    _buildAllRatings(),
                  
                  // レストラン情報
                  if (widget.post.restaurant != null)
                    _buildRestaurantInfo(),
                  
                  // 投稿画像
                  if (widget.post.imageUrl != null)
                    _buildPostImage(),
                  
                  // 投稿統計
                  _buildPostStats(),
                  
                  // アクションボタン
                  _buildActionButtons(),
                  
                  const Divider(height: 1, color: AppColors.border),
                  
                  // コメント一覧
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          
          // コメント入力欄
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アバター
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(widget.post.avatarUrl),
            onBackgroundImageError: (exception, stackTrace) {},
            child: widget.post.avatarUrl.isEmpty 
              ? const Icon(Icons.person, color: Colors.white)
              : null,
          ),
          const SizedBox(width: 12),
          
          // ユーザー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.authorName,
                      style: AppIkyuStyles.dishName,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.post.authorBadge,
                        style: AppIkyuStyles.badge.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.post.formattedTimestamp,
                  style: AppIkyuStyles.timestamp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.post.content,
        style: AppIkyuStyles.bodyText.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _buildAllRatings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '評価',
              style: AppIkyuStyles.dishName.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            if (widget.post.rating!.overall != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StarRating(
                  rating: widget.post.rating!.overall,
                  label: '総合',
                ),
              ),
            
            if (widget.post.rating!.food != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StarRating(
                  rating: widget.post.rating!.food,
                  label: '料理',
                ),
              ),
            
            if (widget.post.rating!.service != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StarRating(
                  rating: widget.post.rating!.service,
                  label: 'サービス',
                ),
              ),
            
            if (widget.post.rating!.value != null)
              StarRating(
                rating: widget.post.rating!.value,
                label: 'コスパ',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  Widget _buildPostImage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.post.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: AppColors.surface,
            child: const Icon(Icons.image, size: 48, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '${_currentPost.likeCount} いいね',
            style: AppIkyuStyles.caption,
          ),
          const SizedBox(width: 16),
          Text(
            '${_comments.length} コメント',
            style: AppIkyuStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // いいねボタン
          _buildActionButton(
            icon: _currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
            color: _currentPost.isLiked ? Colors.red : AppColors.textSecondary,
            onTap: _toggleLike,
          ),
          
          // コメントボタン
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            color: AppColors.textSecondary,
            onTap: () {
              _commentFocusNode.requestFocus();
            },
          ),
          
          // 共有ボタン
          _buildActionButton(
            icon: Icons.share,
            color: AppColors.textSecondary,
            onTap: _sharePost,
          ),
          
          // 保存ボタン
          _buildActionButton(
            icon: _currentPost.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _currentPost.isSaved ? AppColors.primary : AppColors.textSecondary,
            onTap: _toggleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アバター
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 12),
          
          // コメント内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: AppIkyuStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.getTimeAgo(),
                      style: AppIkyuStyles.timestamp,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppIkyuStyles.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          // アバター
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 12),
          
          // 入力欄
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              style: AppIkyuStyles.bodyText,
              decoration: InputDecoration(
                hintText: 'コメントを入力...',
                hintStyle: AppIkyuStyles.placeholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          
          // 送信ボタン
          GestureDetector(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // いいねボタンの機能
  void _toggleLike() {
    setState(() {
      _currentPost = _currentPost.copyWith(
        isLiked: !_currentPost.isLiked,
        likeCount: _currentPost.isLiked 
            ? _currentPost.likeCount - 1 
            : _currentPost.likeCount + 1,
      );
    });
    
    // 元のコールバックも呼び出す（親画面での状態更新のため）
    if (widget.onLike != null) {
      widget.onLike!();
    }
    
    // フィードバック表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentPost.isLiked ? 'いいねしました' : 'いいねを取り消しました'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 保存ボタンの機能
  void _toggleSave() {
    setState(() {
      _currentPost = _currentPost.copyWith(
        isSaved: !_currentPost.isSaved,
      );
    });
    
    // 元のコールバックも呼び出す
    if (widget.onSave != null) {
      widget.onSave!();
    }
    
    // フィードバック表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentPost.isSaved ? '投稿を保存しました' : '保存を取り消しました'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 共有機能
  void _sharePost() {
    // 元のコールバックも呼び出す
    if (widget.onShare != null) {
      widget.onShare!();
    } else {
      // デフォルトの共有機能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投稿をシェアしました'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}