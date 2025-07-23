import 'package:flutter/material.dart';
import '../widgets/plus_menu.dart';
import '../widgets/inline_plus_menu.dart';
import '../widgets/inline_camera_menu.dart';
import '../screens/photo_edit_screen.dart';
import '../models/bgm.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

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
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlusMenuExpanded = false;
  bool _isCameraMenuExpanded = false;
  Bgm? _selectedBgm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile avatar and basic info
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(1000),
              image: const DecorationImage(
                image: NetworkImage("https://placehold.co/96x96"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // User name and handle
          Text(
            widget.userName,
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
            widget.userHandle,
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
              _buildGenreTag('イタリアン'),
              const SizedBox(width: 8),
              _buildGenreTag('カフェ'),
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
          const Text(
            '東京を中心に美味しいお店を探索中🍽️\nイタリアンで美味しいお店あったら教えてください☕',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.77,
            ),
          ),
          const SizedBox(height: 16),
          
          // Settings button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.settings,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
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
    return Container(
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
    );
  }


  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.secondary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: '投稿'),
          Tab(text: '保存済み'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsTab(),
        _buildSavedPostsTab(),
      ],
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        // 投稿入力エリア
        _buildPostInputArea(),
        
        // インラインプラスメニュー
        InlinePlusMenu(
          isExpanded: _isPlusMenuExpanded,
          onToggle: () {
            setState(() {
              _isPlusMenuExpanded = false;
            });
          },
          onBgmSelected: (bgm) {
            setState(() {
              _selectedBgm = bgm;
            });
            print('BGM selected: ${bgm.title} by ${bgm.artist}');
          },
        ),
        
        // インラインカメラメニュー
        InlineCameraMenu(
          isExpanded: _isCameraMenuExpanded,
          onToggle: () {
            setState(() {
              _isCameraMenuExpanded = false;
            });
          },
          onPhotoSelected: (index, color) {
            // 写真が選択されたときの処理
            print('Profile: Photo $index selected');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoEditScreen(
                  photoIndex: index,
                  photoColor: color,
                ),
              ),
            );
          },
        ),
        
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
        
        // 投稿一覧
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPostCard(
                hasImage: true,
                content: 'Body text for a post.\nbrah brah brah',
                timestamp: '12:00　05/11',
              ),
              const SizedBox(height: 20),
              _buildPostCard(
                hasImage: false,
                content: 'Body text for a post. Since it\'s a social app, sometimes it\'s a hot take, and sometimes it\'s a question.',
                timestamp: '12:00　05/11',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          // プラスアイコン
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlusMenuExpanded = !_isPlusMenuExpanded;
                // カメラメニューを閉じる
                if (_isPlusMenuExpanded) {
                  _isCameraMenuExpanded = false;
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedRotation(
                turns: _isPlusMenuExpanded ? 0.125 : 0, // 45度回転
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // カメラアイコン
          GestureDetector(
            onTap: () {
              setState(() {
                _isCameraMenuExpanded = !_isCameraMenuExpanded;
                // プラスメニューを閉じる
                if (_isCameraMenuExpanded) {
                  _isPlusMenuExpanded = false;
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedRotation(
                turns: _isCameraMenuExpanded ? 0.125 : 0, // 45度回転
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.photo_camera,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 投稿入力フィールド
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '今何をしていますか？',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSavedPostsTab() {
    // TODO: 実際の保存済み投稿を表示
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('アカウントと設定'),
                  const SizedBox(height: 20),
                  _buildSettingsItem(Icons.account_circle_outlined, 'アカウント情報'),
                  const Divider(color: Color(0xCC979797), thickness: 0.5),
                  _buildSettingsItem(Icons.group_add_outlined, '友達をフォロー・招待する'),
                  const Divider(color: Color(0xCCDADADA), thickness: 3),
                  _buildSettingsItem(Icons.notifications_outlined, '通知'),
                  _buildSettingsItem(Icons.emoji_events_outlined, 'バッジ'),
                  _buildSettingsItem(Icons.lock_outlined, 'プライバシー'),
                  const Divider(color: Color(0xCCDADADA), thickness: 3),
                  _buildSettingsItem(Icons.security_outlined, 'セキュリティ'),
                  _buildSettingsItem(Icons.payment_outlined, '支払い方法'),
                  _buildSettingsItem(Icons.campaign_outlined, '広告'),
                  _buildSettingsItem(Icons.palette_outlined, 'テーマ'),
                  const Divider(color: Color(0xCCDADADA), thickness: 3),
                  _buildSettingsItem(Icons.help_outline, 'ヘルプ'),
                  _buildSettingsItem(Icons.info_outline, '基本データ'),
                  const Divider(color: Color(0xCCDADADA), thickness: 3),
                  _buildBlueTextItem('Account Center'),
                  const SizedBox(height: 20),
                  _buildSettingsItem(Icons.login, 'ログイン情報'),
                  _buildBlueTextItem('アカウントを追加'),
                  _buildRedTextItem('ログアウト'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          const Expanded(
            child: Text(
              '設定',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.black,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueTextItem(String title) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0282D1),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildRedTextItem(String title) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFEB4D4D),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}