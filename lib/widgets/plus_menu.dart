import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PlusMenu extends StatelessWidget {
  final VoidCallback? onClose;

  const PlusMenu({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドルバー
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // メニューアイテム
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildMenuGrid(),
                const SizedBox(height: 20),
                _buildCloseButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      _MenuItem(
        icon: Icons.music_note,
        label: 'BGM',
        color: Colors.purple,
        onTap: () => print('BGM tapped'),
      ),
      _MenuItem(
        icon: Icons.alternate_email,
        label: 'メンション',
        color: Colors.blue,
        onTap: () => print('メンション tapped'),
      ),
      _MenuItem(
        icon: Icons.mic,
        label: 'AI音声',
        color: Colors.orange,
        onTap: () => print('AI音声 tapped'),
      ),
      _MenuItem(
        icon: Icons.location_on,
        label: '位置情報',
        color: Colors.red,
        onTap: () => print('位置情報 tapped'),
      ),
      _MenuItem(
        icon: Icons.quiz,
        label: 'アンケート',
        color: Colors.green,
        onTap: () => print('アンケート tapped'),
      ),
      _MenuItem(
        icon: Icons.how_to_vote,
        label: '投票',
        color: Colors.teal,
        onTap: () => print('投票 tapped'),
      ),
      _MenuItem(
        icon: Icons.event,
        label: '日程調整',
        color: Colors.indigo,
        onTap: () => print('日程調整 tapped'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: () {
        item.onTap();
        if (onClose != null) onClose!();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'キャンセル',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

void showPlusMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => PlusMenu(
      onClose: () => Navigator.pop(context),
    ),
  );
}