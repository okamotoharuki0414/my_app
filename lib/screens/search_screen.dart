import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/trend.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../widgets/post_card_simple.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _searchHistory = [
    'イタリアンレストラン',
    '渋谷 ランチ',
    '#おすすめカフェ',
    '和食',
    '寿司 銀座',
  ];
  List<Post> _searchResults = [];

  // トレンドデータ
  final List<Trend> _trends = [
    Trend(
      tag: '#新宿グルメ',
      postsCount: '1,234件の投稿',
      category: 'トレンド',
      isPromoted: false,
    ),
    Trend(
      tag: '#ラーメン',
      postsCount: '856件の投稿',
      category: 'グルメ',
      isPromoted: true,
    ),
    Trend(
      tag: '#カフェ巡り',
      postsCount: '2,567件の投稿',
      category: 'トレンド',
      isPromoted: false,
    ),
    Trend(
      tag: '#焼肉',
      postsCount: '698件の投稿',
      category: 'グルメ',
      isPromoted: false,
    ),
    Trend(
      tag: '#デート',
      postsCount: '1,892件の投稿',
      category: 'ライフスタイル',
      isPromoted: false,
    ),
    Trend(
      tag: '#表参道',
      postsCount: '445件の投稿',
      category: 'エリア',
      isPromoted: false,
    ),
    Trend(
      tag: '#スイーツ',
      postsCount: '3,221件の投稿',
      category: 'グルメ',
      isPromoted: true,
    ),
    Trend(
      tag: '#フレンチ',
      postsCount: '334件の投稿',
      category: 'グルメ',
      isPromoted: false,
    ),
    Trend(
      tag: '#韓国料理',
      postsCount: '876件の投稿',
      category: 'グルメ',
      isPromoted: false,
    ),
    Trend(
      tag: '#おしゃれランチ',
      postsCount: '1,555件の投稿',
      category: 'トレンド',
      isPromoted: false,
    ),
  ];

  // カテゴリ別トレンド
  final Map<String, List<Trend>> _categorizedTrends = {};

  @override
  void initState() {
    super.initState();
    _categorizeTrends();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _categorizeTrends() {
    for (final trend in _trends) {
      if (!_categorizedTrends.containsKey(trend.category)) {
        _categorizedTrends[trend.category] = [];
      }
      _categorizedTrends[trend.category]!.add(trend);
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // 検索履歴に追加
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }

    // TODO: 実際の検索ロジックを実装
    // 今はダミーデータを返す
    setState(() {
      _searchResults = _getDummySearchResults(query);
    });
  }

  List<Post> _getDummySearchResults(String query) {
    // ダミーの検索結果
    return [
      Post(
        id: 'search1',
        authorName: 'ユキ',
        authorBadge: 'フードブロガー',
        authorBadgeIds: ['food_photographer'],
        avatarUrl: 'https://placehold.co/32x32',
        content: query.contains('ラーメン') 
          ? '新宿で絶品ラーメンを発見！🍜 スープが濃厚で最高でした。'
          : query.contains('カフェ')
            ? '表参道の隠れ家カフェ☕ 雰囲気が良くて勉強にもぴったり。'
            : 'こちらの${query}に関する投稿です。美味しいお店を見つけました！',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        likeCount: 15,
        commentCount: 3,
      ),
      Post(
        id: 'search2',
        authorName: 'タロウ',
        authorBadge: 'レビュワー',
        authorBadgeIds: ['expert_reviewer'],
        avatarUrl: 'https://placehold.co/32x32',
        content: query.contains('ラーメン')
          ? '#ラーメン 今日のランチはここで決まり！醤油ベースが絶品。'
          : query.contains('カフェ')
            ? '#カフェ巡り 原宿で見つけた可愛いカフェ💕'
            : '${query}について投稿します。おすすめのお店情報です。',
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
        likeCount: 8,
        commentCount: 1,
      ),
    ];
  }

  void _onTrendTap(Trend trend) {
    _searchController.text = trend.tag;
    _performSearch(trend.tag);
    FocusScope.of(context).unfocus();
  }

  void _onHistoryTap(String query) {
    _searchController.text = query;
    _performSearch(query);
    FocusScope.of(context).unfocus();
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 戻るボタン
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 検索バー
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: '投稿を検索',
                      hintStyle: const TextStyle(
                        fontFamily: 'NotoSansJP',
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: _performSearch,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _searchResults.isNotEmpty
        ? _buildSearchResults()
        : _isSearching
          ? _buildSearchHistory()
          : _buildTrendsPage(),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return PostCardSimple(
          post: post,
          onLike: () {
            setState(() {
              _searchResults[index] = post.copyWith(
                isLiked: !post.isLiked,
                likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
              );
            });
          },
          onSave: () {
            setState(() {
              _searchResults[index] = post.copyWith(isSaved: !post.isSaved);
            });
            print('Post ${post.id} saved: ${!post.isSaved}');
          },
        );
      },
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近の検索',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _clearSearchHistory,
                  child: Text(
                    'すべて削除',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_searchHistory.length, (index) {
            final query = _searchHistory[index];
            return ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.grey[600],
                size: 20,
              ),
              title: Text(
                query,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    _searchHistory.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
              onTap: () => _onHistoryTap(query),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTrendsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // トレンド一覧
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'あなたへのおすすめ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          
          // 全体のトレンド（上位5件）
          _buildTrendSection('トレンド', _trends.take(5).toList()),
          
          // カテゴリ別トレンド
          ..._categorizedTrends.entries.map((entry) {
            return _buildTrendSection(entry.key, entry.value.take(3).toList());
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendSection(String title, List<Trend> trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        ...trends.map((trend) => _buildTrendItem(trend)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTrendItem(Trend trend) {
    return InkWell(
      onTap: () => _onTrendTap(trend),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (trend.isPromoted) ...[
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'プロモーション',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${trend.category}のトレンド',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trend.tag,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trend.postsCount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}