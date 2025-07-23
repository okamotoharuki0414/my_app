import 'package:flutter/material.dart';

class DetailedFilterScreen extends StatefulWidget {
  const DetailedFilterScreen({super.key});

  @override
  State<DetailedFilterScreen> createState() => _DetailedFilterScreenState();
}

class _DetailedFilterScreenState extends State<DetailedFilterScreen> {
  // Filter states
  Map<String, bool> selectedGenres = {
    'レストラン': false,
    'カフェ': true,
    'ファストフード': false,
    '居酒屋': false,
    'バー': false,
  };

  Map<String, bool> selectedDetailedGenres = {
    '中華料理': false,
    'イタリアン': true,
    'フレンチ': false,
    '日本料理': false,
    'アジアン': false,
    'ラーメン': false,
    'うどん・そば': false,
    '洋食': false,
    '海鮮': false,
  };

  String selectedBusinessHours = '現在営業中';
  String selectedPriceRange = '安価';
  String selectedRating = '高評価';
  String selectedSortOrder = '新着順';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildBusinessHoursSection(),
                    const SizedBox(height: 24),
                    _buildGenreSection(),
                    const SizedBox(height: 24),
                    _buildDetailedGenreSection(),
                    const SizedBox(height: 24),
                    _buildPriceSection(),
                    const SizedBox(height: 24),
                    _buildRatingSection(),
                    const SizedBox(height: 24),
                    _buildAreaSection(),
                    const SizedBox(height: 24),
                    _buildSortOrderSection(),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              '詳細フィルタ',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.56,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _resetAllFilters,
              child: const Text(
                'すべてリセット',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDADADA)),
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 17),
          const Text(
            'Search',
            style: TextStyle(
              color: Color(0xFF828282),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            child: const Icon(
              Icons.search,
              color: Color(0xFF828282),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHoursSection() {
    return _buildFilterSection(
      title: '営業時間',
      child: Row(
        children: [
          _buildPillButton('現在営業中', selectedBusinessHours == '現在営業中', () {
            setState(() => selectedBusinessHours = '現在営業中');
          }),
          const SizedBox(width: 11),
          _buildPillButton('すべて', selectedBusinessHours == 'すべて', () {
            setState(() => selectedBusinessHours = 'すべて');
          }),
          const SizedBox(width: 11),
          _buildPillButton('カスタム', selectedBusinessHours == 'カスタム', () {
            setState(() => selectedBusinessHours = 'カスタム');
          }),
        ],
      ),
    );
  }

  Widget _buildGenreSection() {
    return _buildFilterSection(
      title: 'ジャンル',
      child: Column(
        children: selectedGenres.entries.map((entry) {
          return _buildCheckboxTile(
            entry.key,
            entry.value,
            (value) {
              setState(() {
                selectedGenres[entry.key] = value ?? false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedGenreSection() {
    return _buildFilterSection(
      title: '詳細なジャンル',
      child: Column(
        children: selectedDetailedGenres.entries.map((entry) {
          return _buildCheckboxTile(
            entry.key,
            entry.value,
            (value) {
              setState(() {
                selectedDetailedGenres[entry.key] = value ?? false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSection() {
    return _buildFilterSection(
      title: '価格',
      child: Row(
        children: [
          _buildPillButton('安価', selectedPriceRange == '安価', () {
            setState(() => selectedPriceRange = '安価');
          }),
          const SizedBox(width: 11),
          _buildPillButton('普通', selectedPriceRange == '普通', () {
            setState(() => selectedPriceRange = '普通');
          }),
          const SizedBox(width: 11),
          _buildPillButton('高価', selectedPriceRange == '高価', () {
            setState(() => selectedPriceRange = '高価');
          }),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return _buildFilterSection(
      title: '評価',
      child: Row(
        children: [
          _buildPillButton('高評価', selectedRating == '高評価', () {
            setState(() => selectedRating = '高評価');
          }),
          const SizedBox(width: 11),
          _buildPillButton('低評価', selectedRating == '低評価', () {
            setState(() => selectedRating = '低評価');
          }),
          const SizedBox(width: 11),
          _buildPillButton('すべて', selectedRating == 'すべて', () {
            setState(() => selectedRating = 'すべて');
          }),
        ],
      ),
    );
  }

  Widget _buildAreaSection() {
    return _buildFilterSection(
      title: 'エリア',
      child: Column(
        children: [
          _buildAreaOption('現在地から検索', Icons.location_on),
          const SizedBox(height: 12),
          _buildAreaOption('都道府県から選択', Icons.map),
        ],
      ),
    );
  }

  Widget _buildSortOrderSection() {
    final options = ['新着順', '人気順', '距離順'];
    
    return _buildFilterSection(
      title: '並び順',
      child: Column(
        children: options.map((option) {
          return _buildRadioTile(
            option,
            selectedSortOrder == option,
            () {
              setState(() => selectedSortOrder = option);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildPillButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6AD314) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF374151),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      height: 41,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF6AD314) : Colors.white,
              border: Border.all(
                color: value ? const Color(0xFF1F2937) : Colors.grey,
                width: value ? 1 : 0.5,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 50),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, bool value, VoidCallback onTap) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF6AD314) : Colors.transparent,
                border: Border.all(
                  color: value ? const Color(0xFF6AD314) : Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaOption(String title, IconData icon) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF374151),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF374151),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      height: 109,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Container(
          width: 322,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF6AD314),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextButton(
            onPressed: () {
              // Apply filters and return to previous screen
              Navigator.pop(context);
            },
            child: const Text(
              'この条件で検索する',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      selectedGenres.updateAll((key, value) => false);
      selectedDetailedGenres.updateAll((key, value) => false);
      selectedBusinessHours = '現在営業中';
      selectedPriceRange = '安価';
      selectedRating = '高評価';
      selectedSortOrder = '新着順';
    });
  }
}