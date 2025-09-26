import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userName;
  final String userHandle;
  final String userBadge;
  final Color badgeColor;

  const ProfileEditScreen({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.userBadge,
    required this.badgeColor,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _websiteController;
  late TextEditingController _bioController;
  String _selectedAvatarUrl = "https://placehold.co/96x96";
  bool _isPrivateAccount = false;
  
  // 料理ジャンルのリスト
  final List<String> _cuisineGenres = [
    'イタリアン',
    'カフェ',
    'フレンチ',
    '中華料理',
    '海鮮',
    '日本料理',
    'ラーメン',
    'うどん・そば',
    'アジアン',
    '洋食',
    'バー',
    'ファストフード',
    '居酒屋',
  ];
  
  List<String> _selectedGenres = ['イタリアン', 'カフェ']; // デフォルト選択

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _usernameController = TextEditingController(text: widget.userHandle);
    _websiteController = TextEditingController(text: "");
    _bioController = TextEditingController(
      text: "東京を中心に美味しいお店を探索中🍽️\nイタリアンで美味しいお店あったら教えてください☕",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

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
          'プロフィールを編集',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '完了',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // プロフィール写真セクション
            _buildProfilePhotoSection(),
            const SizedBox(height: 32),
            
            // フォーム入力セクション
            _buildFormSection(),
            const SizedBox(height: 32),
            
            // 料理ジャンル選択セクション
            _buildCuisineGenreSection(),
            const SizedBox(height: 32),
            
            // プライベートアカウント設定
            _buildPrivateAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _changeProfilePhoto,
          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  image: DecorationImage(
                    image: NetworkImage(_selectedAvatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _changeProfilePhoto,
          child: const Text(
            'プロフィール写真を変更',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: '名前',
          hintText: '名前を入力',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _usernameController,
          label: 'ユーザーネーム',
          hintText: 'ユーザーネームを入力',
          prefix: '@',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _websiteController,
          label: 'ウェブサイト',
          hintText: 'https://example.com',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: '自己紹介',
          hintText: '自己紹介を入力',
          maxLines: 4,
          maxLength: 150,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? prefix,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'NotoSansJP',
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'NotoSansJP',
              color: Colors.grey,
              fontSize: 16,
            ),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              fontFamily: 'NotoSansJP',
              color: Colors.black,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '好きな料理ジャンル',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedGenres.length}/3',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '最大3つまで選択できます',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _cuisineGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            return GestureDetector(
              onTap: () => _toggleGenre(genre),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        if (_selectedGenres.length < 3) {
          _selectedGenres.add(genre);
        } else {
          // 最大3つまでのメッセージを表示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最大3つまで選択できます'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Widget _buildPrivateAccountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プライベートアカウント',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'フォロワーのみがあなたの投稿を見ることができます',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPrivateAccount,
                onChanged: (value) {
                  setState(() {
                    _isPrivateAccount = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLinksSection() {
    return const SizedBox.shrink(); // プロフィールリンクセクションを削除
  }

  Widget _buildProfileLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
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
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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

  void _changeProfilePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'プロフィール写真を変更',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPhotoOption(
              icon: Icons.camera_alt,
              title: 'カメラで撮影',
              onTap: () {
                Navigator.pop(context);
                // カメラ機能の実装
                setState(() {
                  _selectedAvatarUrl = "https://placehold.co/96x96/4CAF50/FFFFFF";
                });
              },
            ),
            _buildPhotoOption(
              icon: Icons.photo_library,
              title: 'ライブラリから選択',
              onTap: () {
                Navigator.pop(context);
                // ライブラリ選択機能の実装
                setState(() {
                  _selectedAvatarUrl = "https://placehold.co/96x96/2196F3/FFFFFF";
                });
              },
            ),
            _buildPhotoOption(
              icon: Icons.delete,
              title: '現在の写真を削除',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedAvatarUrl = "https://placehold.co/96x96";
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.black,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color ?? Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    // プロフィール保存処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィールが更新されました'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // 変更された情報を返す
    Navigator.pop(context, {
      'userName': _nameController.text,
      'userHandle': _usernameController.text,
      'bio': _bioController.text,
      'website': _websiteController.text,
      'avatarUrl': _selectedAvatarUrl,
      'isPrivate': _isPrivateAccount,
      'selectedGenres': _selectedGenres,
    });
  }
}