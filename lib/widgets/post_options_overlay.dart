import 'package:flutter/material.dart';

class PostOptionsOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final String authorName;
  final Function(String) onOptionSelected;

  const PostOptionsOverlay({
    super.key,
    required this.onDismiss,
    required this.authorName,
    required this.onOptionSelected,
  });

  @override
  State<PostOptionsOverlay> createState() => _PostOptionsOverlayState();
}

class _PostOptionsOverlayState extends State<PostOptionsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleOptionTap(String option) {
    widget.onOptionSelected(option);
    _dismissOverlay();
  }

  void _dismissOverlay() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {}, // メニュー自体をタップしても閉じないように
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildOptionsMenu(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsMenu() {
    final options = [
      {
        'icon': Icons.not_interested,
        'text': 'この投稿に興味がない',
        'action': 'not_interested',
      },
      {
        'icon': Icons.report_outlined,
        'text': 'この投稿を報告',
        'action': 'report_post',
      },
      {
        'icon': Icons.visibility_off_outlined,
        'text': 'この投稿を非表示',
        'action': 'hide_post',
      },
      {
        'icon': Icons.report_problem_outlined,
        'text': 'このアカウントを報告',
        'action': 'report_account',
      },
      {
        'icon': Icons.block_outlined,
        'text': 'ブロックする',
        'action': 'block_account',
      },
    ];

    return Container(
      width: 160,
      constraints: const BoxConstraints(
        maxHeight: 220,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100]!.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー（最小限）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.authorName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _dismissOverlay,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // オプション一覧
          Column(
            children: options.map((option) => _buildOptionItem(
              icon: option['icon'] as IconData,
              text: option['text'] as String,
              action: option['action'] as String,
              isDestructive: option['action'] == 'block_account' || 
                            option['action'] == 'report_account' ||
                            option['action'] == 'report_post',
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String text,
    required String action,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () => _handleOptionTap(action),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isDestructive ? Colors.red[600] : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: isDestructive ? Colors.red[600] : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}