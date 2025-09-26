import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../widgets/post_card_home.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final Function(Post)? onPostUpdated;

  const CommentsScreen({
    super.key,
    required this.post,
    this.onPostUpdated,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'あなた',
      authorHandle: '@current_user',
      authorBadge: 'ユーザー',
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _currentPost = _currentPost.copyWith(
        comments: [..._currentPost.comments, newComment],
        commentCount: _currentPost.commentCount + 1,
      );
    });

    widget.onPostUpdated?.call(_currentPost);
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  void _toggleCommentLike(int index) {
    final comment = _currentPost.comments[index];
    final updatedComment = comment.copyWith(
      isLiked: !comment.isLiked,
      likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
    );

    setState(() {
      final updatedComments = List<Comment>.from(_currentPost.comments);
      updatedComments[index] = updatedComment;
      _currentPost = _currentPost.copyWith(comments: updatedComments);
    });

    widget.onPostUpdated?.call(_currentPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'コメント',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 元投稿の表示（PostCardコンポーネントを使用）
          PostCardHome(
            post: _currentPost,
            onLike: () {
              setState(() {
                _currentPost = _currentPost.copyWith(
                  isLiked: !_currentPost.isLiked,
                  likeCount: _currentPost.isLiked ? _currentPost.likeCount - 1 : _currentPost.likeCount + 1,
                );
              });
              widget.onPostUpdated?.call(_currentPost);
            },
            showCommentButton: false, // コメントボタンを非表示
            onShare: () {
              // 共有機能は維持
            },
            onSave: () {
              setState(() {
                _currentPost = _currentPost.copyWith(isSaved: !_currentPost.isSaved);
              });
              widget.onPostUpdated?.call(_currentPost);
            },
            onPostUpdated: (updatedPost) {
              setState(() {
                _currentPost = updatedPost;
              });
              widget.onPostUpdated?.call(updatedPost);
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
          
          // コメント一覧
          Expanded(
            child: _currentPost.comments.isEmpty
                ? _buildEmptyComments()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _currentPost.comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(_currentPost.comments[index], index);
                    },
                  ),
          ),
          
          // コメント入力欄
          _buildCommentInput(),
        ],
      ),
    );
  }


  Widget _buildEmptyComments() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'まだコメントがありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '最初のコメントを投稿してみましょう！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アバター
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEAB02),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        comment.authorBadge,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comment.getTimeAgo(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentLike(index),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likes.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: comment.isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // アバター
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            
            // 入力フィールド
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: 'コメントを追加...',
                    hintStyle: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 14,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(),
                ),
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}