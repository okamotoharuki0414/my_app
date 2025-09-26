import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final Function(String) onChanged;
  final bool hasIcon;

  const FilterDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.hasIcon = true,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(
          width: 1,
          color: const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: 96,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  if (widget.hasIcon)
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                ],
              ),
            ),
          ),
          // Divider
          if (_isExpanded)
            Container(
              width: 94,
              height: 0.5,
              color: const Color(0xFFDADADA),
            ),
          // Options
          if (_isExpanded)
            ...widget.options.map((option) {
              final isSelected = option == widget.selectedOption;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onChanged(option);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      width: 96,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: isSelected ? const Color(0xFF6AD314).withOpacity(0.1) : Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF6AD314) : const Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            height: 1.57,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != widget.options.last)
                    Container(
                      width: 94,
                      height: 0.5,
                      color: const Color(0xFFDADADA),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class SortDropdown extends StatefulWidget {
  final String selectedSort;
  final Function(String) onChanged;

  const SortDropdown({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  bool _isExpanded = false;
  final List<String> _sortOptions = ['新着順', '距離順', '関連度順', '人気順'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: 96,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '並べ替え',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: const Color(0xFF1A1A1A),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          if (_isExpanded)
            Container(
              width: 94,
              height: 0.5,
              color: const Color(0xFFDADADA),
            ),
          // Options
          if (_isExpanded)
            ..._sortOptions.map((option) {
              final isSelected = option == widget.selectedSort;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onChanged(option);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      width: 96,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: isSelected ? const Color(0xFF6AD314).withOpacity(0.1) : Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF6AD314) : const Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            height: 1.57,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != _sortOptions.last)
                    Container(
                      width: 94,
                      height: 0.5,
                      color: const Color(0xFFDADADA),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class PriceDropdown extends StatefulWidget {
  final String selectedPrice;
  final Function(String) onChanged;

  const PriceDropdown({
    super.key,
    required this.selectedPrice,
    required this.onChanged,
  });

  @override
  State<PriceDropdown> createState() => _PriceDropdownState();
}

class _PriceDropdownState extends State<PriceDropdown> {
  bool _isExpanded = false;
  final List<String> _priceOptions = ['安価', '普通', '高価'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(
          width: 1,
          color: const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: 68,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '価格',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          if (_isExpanded)
            Container(
              width: 66,
              height: 0.5,
              color: const Color(0xFFDADADA),
            ),
          // Options
          if (_isExpanded)
            ..._priceOptions.map((option) {
              final isSelected = option == widget.selectedPrice;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onChanged(option);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      width: 68,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: isSelected ? const Color(0xFF6AD314).withOpacity(0.1) : Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF6AD314) : const Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            height: 1.57,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != _priceOptions.last)
                    Container(
                      width: 66,
                      height: 0.5,
                      color: const Color(0xFFDADADA),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class GenreDropdown extends StatefulWidget {
  final List<String> selectedGenres;
  final Function(List<String>) onChanged;

  const GenreDropdown({
    super.key,
    required this.selectedGenres,
    required this.onChanged,
  });

  @override
  State<GenreDropdown> createState() => _GenreDropdownState();
}

class _GenreDropdownState extends State<GenreDropdown> {
  bool _isExpanded = false;
  final List<String> _genreOptions = ['肉', '魚', '麺類', 'デザート'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: 96,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ジャンル',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: const Color(0xFF1A1A1A),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          if (_isExpanded)
            Container(
              width: 94,
              height: 0.5,
              color: const Color(0xFFDADADA),
            ),
          // Options
          if (_isExpanded)
            ..._genreOptions.map((option) {
              final isSelected = widget.selectedGenres.contains(option);
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      List<String> newSelection = List.from(widget.selectedGenres);
                      if (isSelected) {
                        newSelection.remove(option);
                      } else {
                        newSelection.add(option);
                      }
                      widget.onChanged(newSelection);
                    },
                    child: Container(
                      width: 96,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: isSelected ? const Color(0xFF6AD314).withOpacity(0.1) : Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF6AD314) : const Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            height: 1.57,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != _genreOptions.last)
                    Container(
                      width: 94,
                      height: 0.5,
                      color: const Color(0xFFDADADA),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}