import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/bgm_selection_screen.dart';
import '../models/bgm.dart';

class InlinePlusMenu extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Function(Bgm)? onBgmSelected;

  const InlinePlusMenu({
    super.key,
    required this.isExpanded,
    this.onToggle,
    this.onBgmSelected,
  });

  @override
  State<InlinePlusMenu> createState() => _InlinePlusMenuState();
}

class _InlinePlusMenuState extends State<InlinePlusMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InlinePlusMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildMenuGrid(),
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
        onTap: () => _handleMenuTap('BGM'),
      ),
      _MenuItem(
        icon: Icons.alternate_email,
        label: 'メンション',
        color: Colors.blue,
        onTap: () => _handleMenuTap('メンション'),
      ),
      _MenuItem(
        icon: Icons.mic,
        label: 'AI音声',
        color: Colors.orange,
        onTap: () => _handleMenuTap('AI音声'),
      ),
      _MenuItem(
        icon: Icons.location_on,
        label: '位置情報',
        color: Colors.red,
        onTap: () => _handleMenuTap('位置情報'),
      ),
      _MenuItem(
        icon: Icons.quiz,
        label: 'アンケート',
        color: Colors.green,
        onTap: () => _handleMenuTap('アンケート'),
      ),
      _MenuItem(
        icon: Icons.how_to_vote,
        label: '投票',
        color: Colors.teal,
        onTap: () => _handleMenuTap('投票'),
      ),
      _MenuItem(
        icon: Icons.event,
        label: '日程調整',
        color: Colors.indigo,
        onTap: () => _handleMenuTap('日程調整'),
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
      onTap: item.onTap,
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

  void _handleMenuTap(String menuType) async {
    print('$menuType tapped');
    
    if (menuType == 'BGM') {
      // BGM選択画面へ遷移
      final selectedBgm = await Navigator.push<Bgm>(
        context,
        MaterialPageRoute(
          builder: (context) => const BgmSelectionScreen(),
        ),
      );
      
      if (selectedBgm != null && widget.onBgmSelected != null) {
        widget.onBgmSelected!(selectedBgm);
      }
    }
    
    // メニューを自動的に閉じる
    if (widget.onToggle != null) {
      widget.onToggle!();
    }
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