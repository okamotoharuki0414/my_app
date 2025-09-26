import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/badge_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../models/post.dart';
import '../widgets/post_card_home.dart';
import '../constants/app_colors.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_morphism_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String userHandle;
  final String userBadge;
  final Color badgeColor;
  
  const UserProfileScreen({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.userBadge,
    required this.badgeColor,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
  
  // 保存済み投稿（グローバル状態）
  static List<Post> _savedPosts = [];

  // 保存済み投稿を取得する静的メソッド
  static List<Post> get savedPosts => _savedPosts;
  
  // 投稿を保存する静的メソッド
  static void savePost(Post post) {
    if (!_savedPosts.any((p) => p.id == post.id)) {
      _savedPosts.add(post);
    }
  }
  
  // 投稿の保存を解除する静的メソッド
  static void unsavePost(Post post) {
    _savedPosts.removeWhere((p) => p.id == post.id);
  }
  
  // 投稿が保存されているかチェックする静的メソッド
  static bool isPostSaved(Post post) {
    return _savedPosts.any((p) => p.id == post.id);
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // プロフィール情報の状態管理
  late String _currentUserName;
  late String _currentUserHandle;
  late String _currentBio;
  late String _currentWebsite;
  late String _currentAvatarUrl;
  late bool _isPrivateAccount;
  late List<String> _selectedGenres;
  
  // サンプル投稿データ
  final List<Post> _userPosts = [
    Post(
      id: 'user_post_1',
      authorName: 'ユーザー',
      authorBadge: 'フード愛好家',
      authorBadgeIds: ['food_lover'],
      avatarUrl: 'https://placehold.co/32x32',
      content: '今日のランチは最高でした！新しいイタリアンレストランを発見🍝',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likeCount: 15,
      commentCount: 3,
    ),
    Post(
      id: 'user_post_2',
      authorName: 'ユーザー',
      authorBadge: 'フード愛好家',
      authorBadgeIds: ['food_lover'],
      avatarUrl: 'https://placehold.co/32x32',
      content: 'カフェでのんびり☕️ここのケーキは絶品です！',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      likeCount: 8,
      commentCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 初期値を設定
    _currentUserName = widget.userName;
    _currentUserHandle = widget.userHandle;
    _currentBio = '東京を中心に美味しいお店を探索中🍽️\nイタリアンで美味しいお店あったら教えてください☕';
    _currentWebsite = '';
    _currentAvatarUrl = 'https://placehold.co/96x96';
    _isPrivateAccount = false;
    _selectedGenres = ['イタリアン', 'カフェ'];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassMorphismScaffold(
          isClearMode: themeProvider.isClearMode,
          appBar: GlassMorphismAppBar(
            title: '',
            automaticallyImplyLeading: false,
            isClearMode: themeProvider.isClearMode,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.menu,
                  size: 24,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildProfileHeader(themeProvider),
              _buildTabBar(themeProvider),
              Expanded(
                child: _buildTabBarView(themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeProvider themeProvider) {
    Widget content = Column(
      children: [
          // Profile avatar and basic info
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(1000),
              image: DecorationImage(
                image: NetworkImage(_currentAvatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // User name and handle
          Text(
            _currentUserName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUserHandle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 8),
          
          // Badge
          Text(
            widget.userBadge,
            style: TextStyle(
              color: widget.badgeColor,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('127', '投稿'),
              _buildStatColumn('2.4K', 'フォロワー'),
              _buildStatColumn('892', 'フォロー'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Additional info
          const Text(
            '総レビュー店舗数　12',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.92,
            ),
          ),
          const SizedBox(height: 8),
          
          // Favorite genres
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '好きな料理ジャンル',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.92,
                ),
              ),
              const SizedBox(width: 8),
              ..._selectedGenres.take(2).map((genre) => [
                _buildGenreTag(genre),
                const SizedBox(width: 8),
              ]).expand((x) => x).toList(),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton('プロフィールを編集'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton('プロフィールをシェア'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bio
          Text(
            _currentBio,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.77,
            ),
          ),
      ],
    );
    
    if (themeProvider.isClearMode) {
      return GlassMorphismContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        isClearMode: true,
        child: content,
      );
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreTag(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB).withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Color(0xFF50555C),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return GestureDetector(
      onTap: () => _handleActionButtonTap(text),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 2.09,
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionButtonTap(String buttonText) {
    switch (buttonText) {
      case 'プロフィールを編集':
        _editProfile();
        break;
      case 'プロフィールをシェア':
        _shareProfile();
        break;
    }
  }

  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(
          userName: _currentUserName,
          userHandle: _currentUserHandle,
          userBadge: widget.userBadge,
          badgeColor: widget.badgeColor,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      // プロフィール情報を更新
      setState(() {
        _currentUserName = result['userName'] ?? _currentUserName;
        _currentUserHandle = result['userHandle'] ?? _currentUserHandle;
        _currentBio = result['bio'] ?? _currentBio;
        _currentWebsite = result['website'] ?? _currentWebsite;
        _currentAvatarUrl = result['avatarUrl'] ?? _currentAvatarUrl;
        _isPrivateAccount = result['isPrivate'] ?? _isPrivateAccount;
        _selectedGenres = List<String>.from(result['selectedGenres'] ?? _selectedGenres);
      });
      
      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プロフィールが更新されました'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShareModal(),
    );
  }

  Widget _buildShareModal() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'プロフィールをシェア',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                
                // SNS共有オプション
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.link,
                        label: 'リンクを\nコピー',
                        color: Colors.blue,
                        onTap: () => _copyProfileLink(),
                      ),
                    ),
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.message,
                        label: 'メッセージ',
                        color: Colors.green,
                        onTap: () => _shareToMessages(),
                      ),
                    ),
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.mail,
                        label: 'メール',
                        color: Colors.orange,
                        onTap: () => _shareToEmail(),
                      ),
                    ),
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.share,
                        label: 'その他',
                        color: Colors.grey[600]!,
                        onTap: () => _shareToOther(),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Twitter風のシェアテキスト
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'シェア内容',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            '${_currentUserName}さんのプロフィールをチェック！\n$_currentUserHandle\n\n${_currentBio.split('\n').first}\n\nhttps://app.example.com/profile/${_currentUserHandle.replaceAll('@', '')}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _copyProfileLink() {
    Navigator.pop(context);
    // プロフィールリンクをクリップボードにコピー
    final profileLink = 'https://app.example.com/profile/${_currentUserHandle.replaceAll('@', '')}';
    
    // Clipboard.setData(ClipboardData(text: profileLink)); // 実装時に使用
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィールリンクをコピーしました'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToMessages() {
    Navigator.pop(context);
    final shareText = '${_currentUserName}さんのプロフィールをチェック！\nhttps://app.example.com/profile/${_currentUserHandle.replaceAll('@', '')}';
    
    // メッセージアプリへの共有実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('メッセージアプリで共有しました'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToEmail() {
    Navigator.pop(context);
    final shareText = '${_currentUserName}さんのプロフィールをチェック！\n${_currentUserHandle}\n\n${_currentBio.split('\n').first}\n\nhttps://app.example.com/profile/${_currentUserHandle.replaceAll('@', '')}';
    
    // メールアプリへの共有実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('メールアプリで共有しました'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToOther() {
    Navigator.pop(context);
    final shareText = '${_currentUserName}さんのプロフィールをチェック！\n${_currentUserHandle}\n\n${_currentBio.split('\n').first}\n\nhttps://app.example.com/profile/${_currentUserHandle.replaceAll('@', '')}';
    
    // その他のアプリへの共有実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('他のアプリで共有しました'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ),
    );
  }


  Widget _buildTabBar(ThemeProvider themeProvider) {
    Widget tabBar = TabBar(
      controller: _tabController,
      labelColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.secondary,
      indicatorWeight: 2,
      tabs: const [
        Tab(text: '投稿'),
        Tab(text: '保存済み'),
        Tab(text: 'バッジ'),
      ],
    );
    
    if (themeProvider.isClearMode) {
      return GlassMorphismContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        isClearMode: true,
        child: tabBar,
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: tabBar,
    );
  }

  Widget _buildTabBarView(ThemeProvider themeProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsTab(themeProvider),
        _buildSavedPostsTab(themeProvider),
        _buildBadgesTab(themeProvider),
      ],
    );
  }

  Widget _buildPostsTab(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 1),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE1E8ED), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー情報とタイムスタンプ
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage("https://placehold.co/48x48"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.userName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.userBadge,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: widget.badgeColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '・',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.formattedTimestamp,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 投稿内容
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 画像（もしあれば）
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage("https://placehold.co/400x200"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // アクションボタン（Twitter風）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTwitterActionButton(
                      Icons.chat_bubble_outline,
                      '${post.commentCount}',
                      Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      Icons.repeat,
                      '23',
                      Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      '${post.likeCount}',
                      post.isLiked ? Colors.red : Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      UserProfileScreen.isPostSaved(post) ? Icons.bookmark : Icons.bookmark_border,
                      '',
                      UserProfileScreen.isPostSaved(post) ? Colors.blue : Colors.grey[600]!,
                      () {
                        setState(() {
                          if (UserProfileScreen.isPostSaved(post)) {
                            UserProfileScreen.unsavePost(post);
                          } else {
                            UserProfileScreen.savePost(post);
                          }
                        });
                      },
                    ),
                    _buildTwitterActionButton(
                      Icons.share,
                      '',
                      Colors.grey[600]!,
                      () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTwitterActionButton(IconData icon, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPostsTab(ThemeProvider themeProvider) {
    if (UserProfileScreen.savedPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '保存済みの投稿がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '気に入った投稿を保存してみましょう！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: UserProfileScreen.savedPosts.length,
      itemBuilder: (context, index) {
        final post = UserProfileScreen.savedPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 1),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE1E8ED), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー情報とタイムスタンプ
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage("https://placehold.co/48x48"),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                                  post.authorName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  post.authorBadge,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '・',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  post.formattedTimestamp,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 保存済み投稿マーク
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: 12,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '保存済み',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 投稿内容
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 画像（もしあれば）
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage("https://placehold.co/400x200"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // アクションボタン（Twitter風）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTwitterActionButton(
                      Icons.chat_bubble_outline,
                      '${post.commentCount}',
                      Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      Icons.repeat,
                      '23',
                      Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      '${post.likeCount}',
                      post.isLiked ? Colors.red : Colors.grey[600]!,
                      () {},
                    ),
                    _buildTwitterActionButton(
                      Icons.bookmark,
                      '',
                      Colors.blue,
                      () {
                        setState(() {
                          UserProfileScreen.unsavePost(post);
                        });
                      },
                    ),
                    _buildTwitterActionButton(
                      Icons.share,
                      '',
                      Colors.grey[600]!,
                      () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab(ThemeProvider themeProvider) {
    final badges = [
      {'name': 'フード愛好家', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'name': 'グルメ探検家', 'icon': Icons.explore, 'color': Colors.green},
      {'name': 'レビューマスター', 'icon': Icons.star, 'color': Colors.blue},
      {'name': 'ソーシャル蝶', 'icon': Icons.people, 'color': Colors.purple},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Container(
          decoration: BoxDecoration(
            color: (badge['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (badge['color'] as Color).withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: badge['color'] as Color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                badge['name'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: badge['color'] as Color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostDialog(Post post) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage("https://placehold.co/40x40"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          post.authorBadge,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // 投稿内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage("https://placehold.co/400x300"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // アクションボタン
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  _buildInteractionButton(Icons.thumb_up_outlined, '${post.likeCount}'),
                  const SizedBox(width: 24),
                  _buildInteractionButton(Icons.comment_outlined, '${post.commentCount}'),
                  const SizedBox(width: 24),
                  const Icon(Icons.share_outlined, size: 24, color: Colors.grey),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (UserProfileScreen.isPostSaved(post)) {
                        UserProfileScreen.unsavePost(post);
                      } else {
                        UserProfileScreen.savePost(post);
                      }
                      Navigator.pop(context);
                      setState(() {}); // UI更新
                    },
                    child: Icon(
                      UserProfileScreen.isPostSaved(post) ? Icons.bookmark : Icons.bookmark_border,
                      size: 24,
                      color: UserProfileScreen.isPostSaved(post) ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required bool hasImage,
    required String content,
    required String timestamp,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(1000),
                    image: const DecorationImage(
                      image: NetworkImage("https://placehold.co/32x32"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 4),
                              blurRadius: 4,
                              color: Color(0x33000000),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.userBadge,
                            style: TextStyle(
                              color: widget.badgeColor,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_vert,
                  size: 24,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.40,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Image if present
          if (hasImage)
            Container(
              width: 287,
              height: 219,
              margin: const EdgeInsets.symmetric(horizontal: 42),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/287x219"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Interaction row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInteractionButton(Icons.thumb_up_outlined, '21'),
                const SizedBox(width: 16),
                _buildInteractionButton(Icons.comment_outlined, '4'),
                const SizedBox(width: 16),
                const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                const Spacer(),
                const Icon(Icons.bookmark_border, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
          ),
          child: Icon(
            icon,
            size: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF828282),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
      ],
    );
  }

}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _privateAccount = false;
  bool _dataUsageOptimization = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          '設定',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // アカウントセクション
          _buildSectionHeader('あなたのアカウント'),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'アカウント情報',
            subtitle: 'パスワード、セキュリティ、個人情報、広告設定',
            onTap: () => _showAccountSettings(),
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'プライバシー',
            subtitle: 'アカウントのプライバシー、ブロックしたアカウント',
            onTap: () => _showPrivacySettings(),
          ),
          _buildMenuItem(
            icon: Icons.security,
            title: 'セキュリティ',
            subtitle: '二段階認証、ログインアラート',
            onTap: () => _showSecuritySettings(),
          ),
          _buildMenuItem(
            icon: Icons.campaign_outlined,
            title: '広告',
            subtitle: '広告の設定とデータ',
            onTap: () => _showAdSettings(),
          ),
          
          const SizedBox(height: 24),
          
          // 設定セクション
          _buildSectionHeader('設定'),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: '通知',
            subtitle: 'プッシュ通知、メール、SMS',
            onTap: () => _showNotificationSettings(),
          ),
          _buildSwitchItem(
            icon: Icons.privacy_tip_outlined,
            title: 'プライベートアカウント',
            subtitle: 'フォロワーのみがあなたの投稿を見ることができます',
            value: _privateAccount,
            onChanged: (value) {
              setState(() {
                _privateAccount = value;
              });
            },
          ),
          _buildMenuItem(
            icon: Icons.palette_outlined,
            title: 'テーマ',
            subtitle: 'ダークモード、アプリアイコン',
            onTap: () => _showThemeSettings(),
          ),
          _buildSwitchItem(
            icon: Icons.data_usage,
            title: 'データ使用量',
            subtitle: 'データ使用量を削減',
            value: _dataUsageOptimization,
            onChanged: (value) {
              setState(() {
                _dataUsageOptimization = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // ヘルプセクション
          _buildSectionHeader('ヘルプ'),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'ヘルプ',
            subtitle: 'ヘルプセンター、お問い合わせ、プライバシーポリシー',
            onTap: () => _showHelpSettings(),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'アプリについて',
            subtitle: 'アップデート、利用規約',
            onTap: () => _showAboutApp(),
          ),
          
          const SizedBox(height: 24),
          
          // ログインセクション
          _buildSectionHeader('ログイン'),
          _buildMenuItem(
            icon: Icons.add_circle_outline,
            title: 'アカウントを追加',
            subtitle: '',
            textColor: Colors.blue,
            onTap: () => _addAccount(),
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'ログアウト',
            subtitle: '',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor ?? Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.black,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (textColor == null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  // 設定画面の実装
  void _showAccountSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAccountSettingsModal(),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プライバシー設定を開いています...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('セキュリティ設定を開いています...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAdSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('広告設定を開いています...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationSettingsModal(),
    );
  }

  void _showThemeSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildThemeSettingsModal(),
    );
  }

  void _showHelpSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ヘルプセンターを開いています...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アプリについて'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('レストランソーシャルメディアアプリ'),
            Text('バージョン: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2024 Your Company Name'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _addAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('アカウント追加機能は準備中です'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ログアウトしました'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'ログアウト',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsModal() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'アカウント情報',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('個人情報'),
              subtitle: const Text('名前、メールアドレス、電話番号'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('個人情報設定を開いています...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('パスワード'),
              subtitle: const Text('パスワードを変更'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('パスワード変更画面を開いています...')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsModal() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '通知設定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('プッシュ通知'),
              subtitle: const Text('いいねやコメントの通知'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsModal() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final isClear = themeProvider.isClearMode;
        
        Widget content = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'テーマ設定',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildThemeOption(
                  icon: Icons.brightness_auto,
                  title: 'システム設定に従う',
                  subtitle: '端末の設定に自動で合わせる',
                  isSelected: themeProvider.currentTheme == AppThemeMode.system,
                  onTap: () {
                    themeProvider.setTheme(AppThemeMode.system);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('システム設定に従うモードに設定しました')),
                    );
                  },
                  isDark: isDark,
                ),
                _buildThemeOption(
                  icon: Icons.light_mode,
                  title: 'ライトモード',
                  isSelected: themeProvider.currentTheme == AppThemeMode.light,
                  onTap: () {
                    themeProvider.setTheme(AppThemeMode.light);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ライトモードに設定しました')),
                    );
                  },
                  isDark: isDark,
                ),
                _buildThemeOption(
                  icon: Icons.dark_mode,
                  title: 'ダークモード',
                  isSelected: themeProvider.currentTheme == AppThemeMode.dark,
                  onTap: () {
                    themeProvider.setTheme(AppThemeMode.dark);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ダークモードに設定しました')),
                    );
                  },
                  isDark: isDark,
                ),
                _buildThemeOption(
                  icon: Icons.blur_on,
                  title: 'クリアモード',
                  subtitle: 'iOS風すりガラスデザイン',
                  isSelected: themeProvider.currentTheme == AppThemeMode.clear,
                  onTap: () {
                    themeProvider.setTheme(AppThemeMode.clear);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('クリアモードに設定しました')),
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
        
        // クリアモードの場合はすりガラス効果を適用
        if (isClear) {
          return AppTheme.glassMorphismContainer(
            child: content,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          );
        }
        
        return content;
      },
    );
  }
  
  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
            ? Colors.blue 
            : (isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected 
              ? Colors.blue 
              : (isDark ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: isSelected 
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: onTap,
    );
  }
}