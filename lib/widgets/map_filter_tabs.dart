import 'package:flutter/material.dart';

class MapFilterTabs extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(String) onFilterTap;

  const MapFilterTabs({
    super.key,
    required this.selectedFilters,
    required this.onFilterTap,
  });

  @override
  State<MapFilterTabs> createState() => _MapFilterTabsState();
}

class _MapFilterTabsState extends State<MapFilterTabs> {
  String? _expandedGroup;

  static const Map<String, List<FilterOption>> _filterGroups = {
    'sort': [
      FilterOption(id: 'sort_rating', label: '高評価順'),
      FilterOption(id: 'sort_distance', label: '距離順'),
      FilterOption(id: 'sort_price', label: '価格順'),
    ],
    'price': [
      FilterOption(id: 'price_low', label: '¥'),
      FilterOption(id: 'price_medium', label: '¥¥'),
      FilterOption(id: 'price_high', label: '¥¥¥'),
      FilterOption(id: 'price_luxury', label: '¥¥¥¥'),
    ],
    'category': [
      FilterOption(id: 'category_italian', label: 'イタリアン'),
      FilterOption(id: 'category_japanese', label: '日本料理'),
      FilterOption(id: 'category_cafe', label: 'カフェ'),
      FilterOption(id: 'category_ramen', label: 'ラーメン'),
      FilterOption(id: 'category_french', label: 'フレンチ'),
      FilterOption(id: 'category_sushi', label: '寿司'),
      FilterOption(id: 'category_chinese', label: '中華料理'),
    ],
    'other': [
      FilterOption(id: 'open_now', label: '営業中'),
      FilterOption(id: 'delivery', label: 'デリバリー可'),
      FilterOption(id: 'takeout', label: 'テイクアウト可'),
    ],
  };

  static const Map<String, String> _groupLabels = {
    'sort': '並び替え',
    'price': '価格帯',
    'category': 'カテゴリ',
    'other': 'その他',
  };

  String _getGroupDisplayText(String groupKey) {
    final filters = _filterGroups[groupKey] ?? [];
    final selectedInGroup = filters.where((f) => widget.selectedFilters.contains(f.id)).toList();
    
    if (selectedInGroup.isEmpty) {
      return _groupLabels[groupKey] ?? '';
    }
    
    if (selectedInGroup.length == 1) {
      return selectedInGroup.first.label;
    }
    
    return '${_groupLabels[groupKey]}(${selectedInGroup.length})';
  }

  bool _isGroupSelected(String groupKey) {
    final filters = _filterGroups[groupKey] ?? [];
    return filters.any((f) => widget.selectedFilters.contains(f.id));
  }

  double _getButtonPosition(int index) {
    final buttonWidth = 60.0;
    final spacing = 4.0;
    final startPadding = 8.0;
    return startPadding + (index * (buttonWidth + spacing));
  }

  OverlayEntry? _overlayEntry;
  GlobalKey _filterKey = GlobalKey();

  void _showDropdown(String groupKey, int index) {
    _removeDropdown();
    
    final RenderBox renderBox = _filterKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + _getButtonPosition(index),
        top: offset.dy + size.height + 4,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 8,
          child: Container(
            width: 120,
            constraints: const BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: (_filterGroups[groupKey] ?? []).map((filter) {
                final isSelected = widget.selectedFilters.contains(filter.id);
                
                return InkWell(
                  onTap: () {
                    print('Filter selected: ${filter.label}');
                    widget.onFilterTap(filter.id);
                    _removeDropdown();
                    setState(() {
                      _expandedGroup = null;
                    });
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            filter.label,
                            style: TextStyle(
                              color: isSelected ? Colors.blue[700] : Colors.black87,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _filterKey,
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _filterGroups.keys.length,
        itemBuilder: (context, index) {
          final groupKey = _filterGroups.keys.elementAt(index);
          final isSelected = _isGroupSelected(groupKey);
          final isExpanded = _expandedGroup == groupKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () {
                print('Filter button tapped: $groupKey');
                setState(() {
                  if (_expandedGroup == groupKey) {
                    _expandedGroup = null;
                    _removeDropdown();
                    print('Closing dropdown');
                  } else {
                    _expandedGroup = groupKey;
                    _showDropdown(groupKey, index);
                    print('Opening dropdown for: $groupKey');
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpanded ? Colors.blue.withOpacity(0.1) : (isSelected ? Colors.blue : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded ? Colors.blue : (isSelected ? Colors.blue : Colors.grey[300]!),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGroupDisplayText(groupKey),
                      style: TextStyle(
                        color: isExpanded ? Colors.blue[700] : (isSelected ? Colors.white : Colors.black87),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 12,
                      color: isExpanded ? Colors.blue[700] : (isSelected ? Colors.white : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterOption {
  final String id;
  final String label;

  const FilterOption({
    required this.id,
    required this.label,
  });
}