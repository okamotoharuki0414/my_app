import 'package:flutter/material.dart';
import '../models/user.dart';

class MentionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<User> followers;
  final Function(User) onUserMentioned;
  final VoidCallback? onClose;

  const MentionInputWidget({
    super.key,
    required this.controller,
    required this.followers,
    required this.onUserMentioned,
    this.onClose,
  });

  @override
  State<MentionInputWidget> createState() => _MentionInputWidgetState();
}

class _MentionInputWidgetState extends State<MentionInputWidget> {
  List<User> _filteredUsers = [];
  bool _showSuggestions = false;
  String _currentMention = '';
  int _mentionStartPos = -1;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;
    
    // @マークの位置を探す
    int atPos = -1;
    for (int i = cursorPos - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atPos = i;
        break;
      } else if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atPos >= 0 && cursorPos > atPos) {
      // @マークが見つかった場合
      final mentionText = text.substring(atPos + 1, cursorPos);
      _currentMention = mentionText;
      _mentionStartPos = atPos;
      
      // フィルタリング
      if (mentionText.isEmpty) {
        _filteredUsers = widget.followers.take(5).toList();
      } else {
        _filteredUsers = widget.followers
            .where((user) => 
                user.username.toLowerCase().contains(mentionText.toLowerCase()) ||
                user.displayName.toLowerCase().contains(mentionText.toLowerCase()))
            .take(5)
            .toList();
      }
      
      if (_filteredUsers.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alternate_email, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'メンション',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _removeOverlay(),
                        child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                // ユーザーリスト
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserItem(user);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildUserItem(User user) {
    return InkWell(
      onTap: () => _selectUser(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // アバター
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  user.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.person, size: 20, color: Colors.grey[400]),
                  ),
                ),
              ),
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
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (user.badge.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // オンライン状態
            if (user.isOnline)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectUser(User user) {
    final text = widget.controller.text;
    final beforeMention = text.substring(0, _mentionStartPos);
    final afterMention = text.substring(widget.controller.selection.baseOffset);
    
    final mentionText = '@${user.username} ';
    final newText = beforeMention + mentionText + afterMention;
    
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: beforeMention.length + mentionText.length),
    );
    
    widget.onUserMentioned(user);
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // このウィジェット自体は何も表示しない
  }
}