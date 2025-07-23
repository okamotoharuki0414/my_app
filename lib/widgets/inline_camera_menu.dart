import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InlineCameraMenu extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Function(int index, Color color)? onPhotoSelected;

  const InlineCameraMenu({
    super.key,
    required this.isExpanded,
    this.onToggle,
    this.onPhotoSelected,
  });

  @override
  State<InlineCameraMenu> createState() => _InlineCameraMenuState();
}

class _InlineCameraMenuState extends State<InlineCameraMenu>
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
  void didUpdateWidget(InlineCameraMenu oldWidget) {
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
    print('Building InlineCameraMenu, isExpanded: ${widget.isExpanded}'); // デバッグ用
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
    print('Building menu grid with 9 items'); // デバッグ用
    // 9枚の写真グリッド（最初の1枚はカメラアイコン）
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        print('GridView itemBuilder called for index $index'); // デバッグ用
        return _buildPhotoItem(index);
      },
    );
  }

  Widget _buildPhotoItem(int index) {
    print('Building photo item $index'); // デバッグ用
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Photo item $index tapped!'); // タップ確認用
          if (index == 0) {
            // 一番左上はカメラ起動
            print('Camera button tapped');
            _handleMenuTap('カメラ起動');
          } else {
            // 写真選択後、コールバックで親に通知
            print('Photo $index selected, calling callback...');
            if (widget.onPhotoSelected != null) {
              widget.onPhotoSelected!(index, _getPhotoColor(index));
            }
            
            // メニューを閉じる
            if (widget.onToggle != null) {
              widget.onToggle!();
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: index == 0 
            ? Container(
                color: Colors.grey[100],
                child: const Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Colors.grey,
                ),
              )
            : Container(
                color: _getPhotoColor(index),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        ),
        ),
      ),
    );
  }

  Color _getPhotoColor(int index) {
    final colors = [
      Colors.red[300]!,
      Colors.green[300]!,
      Colors.blue[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.teal[300]!,
      Colors.pink[300]!,
      Colors.amber[300]!,
    ];
    return colors[(index - 1) % colors.length];
  }

  void _handleMenuTap(String menuType) {
    print('$menuType tapped');
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