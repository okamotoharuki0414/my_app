import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import 'dart:convert';

/// ユーザーの興味・関心を管理するサービスクラス
class UserInterestService {
  static const String _dislikedPostsKey = 'disliked_posts';
  static const String _dislikedCategoriesKey = 'disliked_categories';
  static const String _dislikedKeywordsKey = 'disliked_keywords';

  /// 「興味がない」と判定された投稿のIDリスト
  static Set<String> _dislikedPosts = {};
  
  /// 「興味がない」と判定されたカテゴリ（レストランの種類など）
  static Set<String> _dislikedCategories = {};
  
  /// 「興味がない」と判定されたキーワード
  static Set<String> _dislikedKeywords = {};

  /// 初期化 - アプリ起動時に呼び出す
  static Future<void> initialize() async {
    await _loadDislikedData();
  }

  /// SharedPreferencesから興味がないデータを読み込み
  static Future<void> _loadDislikedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 興味がない投稿IDを読み込み
    final dislikedPostsJson = prefs.getStringList(_dislikedPostsKey) ?? [];
    _dislikedPosts = dislikedPostsJson.toSet();
    
    // 興味がないカテゴリを読み込み
    final dislikedCategoriesJson = prefs.getStringList(_dislikedCategoriesKey) ?? [];
    _dislikedCategories = dislikedCategoriesJson.toSet();
    
    // 興味がないキーワードを読み込み
    final dislikedKeywordsJson = prefs.getStringList(_dislikedKeywordsKey) ?? [];
    _dislikedKeywords = dislikedKeywordsJson.toSet();
    
    print('興味がないデータを読み込み: 投稿=${_dislikedPosts.length}, カテゴリ=${_dislikedCategories.length}, キーワード=${_dislikedKeywords.length}');
  }

  /// 興味がないデータをSharedPreferencesに保存
  static Future<void> _saveDislikedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList(_dislikedPostsKey, _dislikedPosts.toList());
    await prefs.setStringList(_dislikedCategoriesKey, _dislikedCategories.toList());
    await prefs.setStringList(_dislikedKeywordsKey, _dislikedKeywords.toList());
  }

  /// 投稿を「興味がない」として記録
  static Future<void> markPostAsNotInterested(Post post) async {
    // 投稿IDを記録
    _dislikedPosts.add(post.id);
    
    // レストランカテゴリがある場合は記録
    if (post.restaurant != null && post.restaurant!.category.isNotEmpty) {
      _dislikedCategories.add(post.restaurant!.category);
      print('興味がないカテゴリに追加: ${post.restaurant!.category}');
    }
    
    // 投稿内容からキーワードを抽出して記録
    _extractAndAddKeywords(post.content);
    
    // 投稿のバッジからもキーワードを抽出
    if (post.authorBadge.isNotEmpty) {
      _dislikedKeywords.add(post.authorBadge);
    }
    
    // 保存
    await _saveDislikedData();
    
    print('投稿「${post.id}」を興味がないとして記録しました');
    print('現在の興味がないデータ: 投稿=${_dislikedPosts.length}, カテゴリ=${_dislikedCategories.length}, キーワード=${_dislikedKeywords.length}');
  }

  /// 投稿内容からキーワードを抽出
  static void _extractAndAddKeywords(String content) {
    // ハッシュタグを抽出
    final hashtagPattern = RegExp(r'#(\w+)');
    final hashtags = hashtagPattern.allMatches(content);
    for (final match in hashtags) {
      if (match.group(1) != null) {
        _dislikedKeywords.add('#${match.group(1)}');
      }
    }
    
    // よく使われるキーワードを抽出（日本語）
    final commonKeywords = [
      'ラーメン', 'カフェ', 'スイーツ', '焼肉', '寿司', '和食', '洋食', '中華',
      'イタリアン', 'フレンチ', '韓国料理', 'タイ料理', 'ランチ', 'ディナー',
      'デート', '女子会', '家族', '一人', '新宿', '渋谷', '原宿', '表参道',
      '銀座', '六本木', '恵比寿', 'おしゃれ', '美味しい', '絶品', '話題'
    ];
    
    for (final keyword in commonKeywords) {
      if (content.contains(keyword)) {
        _dislikedKeywords.add(keyword);
      }
    }
  }

  /// 投稿がユーザーの興味に合わないかどうかを判定
  static bool shouldHidePost(Post post) {
    // 直接「興味がない」とマークされた投稿
    if (_dislikedPosts.contains(post.id)) {
      return true;
    }
    
    // 興味がないカテゴリの投稿
    if (post.restaurant != null && 
        post.restaurant!.category.isNotEmpty &&
        _dislikedCategories.contains(post.restaurant!.category)) {
      print('カテゴリ「${post.restaurant!.category}」の投稿をフィルタリング');
      return true;
    }
    
    // 興味がないキーワードを含む投稿
    for (final keyword in _dislikedKeywords) {
      if (post.content.contains(keyword) || 
          post.authorBadge.contains(keyword)) {
        print('キーワード「$keyword」の投稿をフィルタリング');
        return true;
      }
    }
    
    return false;
  }

  /// 投稿リストから興味がない投稿をフィルタリング
  static List<Post> filterPosts(List<Post> posts) {
    return posts.where((post) => !shouldHidePost(post)).toList();
  }

  /// 興味がないデータをリセット（デバッグ用）
  static Future<void> resetDislikedData() async {
    _dislikedPosts.clear();
    _dislikedCategories.clear();
    _dislikedKeywords.clear();
    await _saveDislikedData();
    print('興味がないデータをリセットしました');
  }

  /// 現在の興味がないデータの統計を取得
  static Map<String, int> getDislikedDataStats() {
    return {
      'posts': _dislikedPosts.length,
      'categories': _dislikedCategories.length,
      'keywords': _dislikedKeywords.length,
    };
  }
}