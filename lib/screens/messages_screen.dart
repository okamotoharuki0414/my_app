import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/message.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Sample conversations data
  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      participantName: 'ダニエル',
      participantAvatar: 'https://placehold.co/56x56',
      lastMessage: '美味しそうな写真ですね！どちらのお店ですか？',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 15)),
      isOnline: true,
      unreadCount: 2,
    ),
    Conversation(
      id: '2',
      participantName: 'エレナ',
      participantAvatar: 'https://placehold.co/56x56',
      lastMessage: 'ありがとうございます！',
      lastMessageTime: DateTime.now().subtract(Duration(hours: 1)),
      isOnline: false,
      unreadCount: 0,
    ),
    Conversation(
      id: '3',
      participantName: 'タカシ',
      participantAvatar: 'https://placehold.co/56x56',
      lastMessage: '今度一緒に行きましょう',
      lastMessageTime: DateTime.now().subtract(Duration(hours: 3)),
      isOnline: true,
      unreadCount: 1,
    ),
    Conversation(
      id: '4',
      participantName: 'ユキ',
      participantAvatar: 'https://placehold.co/56x56',
      lastMessage: 'レビューありがとうございました',
      lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
      isOnline: false,
      unreadCount: 0,
    ),
    Conversation(
      id: '5',
      participantName: 'アヤカ',
      participantAvatar: 'https://placehold.co/56x56',
      lastMessage: 'フォローありがとうございます',
      lastMessageTime: DateTime.now().subtract(Duration(days: 2)),
      isOnline: false,
      unreadCount: 0,
    ),
  ];

  List<Conversation> get _filteredConversations {
    if (_searchController.text.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conversation) =>
        conversation.participantName.toLowerCase().contains(
            _searchController.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'ユーザー名',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call_outlined, color: Colors.black),
            onPressed: () {
              // Video call functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              // New message functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: '検索',
                hintStyle: const TextStyle(
                  fontFamily: 'NotoSansJP',
                  color: Colors.grey,
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          
          // Messages list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = _filteredConversations[index];
                return _buildConversationItem(conversation);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildConversationItem(Conversation conversation) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      conversation.participantAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                // Online indicator
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF42D942),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conversation.participantName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: conversation.unreadCount > 0 
                              ? FontWeight.w600 
                              : FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      Text(
                        _formatMessageTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: conversation.unreadCount > 0 
                              ? Color(0xFF0095F6)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unreadCount > 0 
                                ? Colors.black
                                : Colors.grey[600],
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(0xFF0095F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Camera icon
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
              onPressed: () {
                // Camera functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}日';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分';
    } else {
      return '今';
    }
  }
}