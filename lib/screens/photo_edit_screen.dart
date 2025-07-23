import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PhotoEditScreen extends StatefulWidget {
  final int photoIndex; // 選択した写真のインデックス
  final Color photoColor; // 写真の色（サンプル用）

  const PhotoEditScreen({
    super.key,
    required this.photoIndex,
    required this.photoColor,
  });

  @override
  State<PhotoEditScreen> createState() {
    print('PhotoEditScreen createState called with index: $photoIndex, color: $photoColor');
    return _PhotoEditScreenState();
  }
}

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _onPost() {
    // 投稿処理
    print('投稿: ${_captionController.text}');
    print('選択写真: ${widget.photoIndex}');
    
    // 投稿後は前の画面に戻る
    Navigator.pop(context);
    // さらに写真選択画面も閉じる場合
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '投稿',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _onPost,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '投稿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 写真表示エリア
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.photoColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '写真 ${widget.photoIndex}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 編集ツールバー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEditButton(Icons.crop, 'トリミング'),
                _buildEditButton(Icons.tune, 'フィルター'),
                _buildEditButton(Icons.text_fields, 'テキスト'),
                _buildEditButton(Icons.brush, '描画'),
              ],
            ),
          ),
          
          // キャプション入力エリア
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'キャプションを追加',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '写真について説明してください...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 追加オプション
                  Row(
                    children: [
                      _buildOptionButton(Icons.location_on, '位置情報を追加'),
                      const SizedBox(width: 16),
                      _buildOptionButton(Icons.people, 'タグ付け'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        print('$label tapped');
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        print('$label tapped');
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}