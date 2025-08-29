import 'package:flutter/services.dart';
import '../models/restaurant.dart';

/// CSVファイルからレストランデータを読み取るサービス
class CsvRestaurantService {
  /// assets/data/restaurant_data.csvからレストランデータを読み込む
  static Future<List<Restaurant>> loadRestaurantsFromCsv() async {
    try {
      print('📄 CSVファイルからレストランデータを読み込み開始...');
      
      // CSVファイルを読み込み
      final csvData = await rootBundle.loadString('assets/data/restaurant_data.csv');
      print('✅ CSVファイル読み込み完了');
      
      // CSVデータをパース
      final restaurants = _parseCsvData(csvData);
      print('🍽️ ${restaurants.length}店舗のデータをパース完了');
      
      // カテゴリ別統計を表示
      _printCategoryStats(restaurants);
      
      return restaurants;
    } catch (e) {
      print('❌ CSVファイル読み込みエラー: $e');
      return [];
    }
  }

  /// CSVデータをパースしてレストランリストに変換
  static List<Restaurant> _parseCsvData(String csvData) {
    final List<Restaurant> restaurants = [];
    final lines = csvData.split('\n');
    
    if (lines.isEmpty) {
      print('⚠️ CSVファイルが空です');
      return restaurants;
    }

    // ヘッダー行をスキップ
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final restaurant = _parseRestaurantFromCsvLine(line, i);
        if (restaurant != null) {
          restaurants.add(restaurant);
          print('✓ ${restaurant.name} (${restaurant.latitude}, ${restaurant.longitude})');
        }
      } catch (e) {
        print('⚠️ 行${i + 1}のパースエラー: $e');
        continue;
      }
    }

    return restaurants;
  }

  /// CSV行からレストランオブジェクトを作成
  static Restaurant? _parseRestaurantFromCsvLine(String line, int lineNumber) {
    try {
      final fields = _parseCsvLine(line);
      
      if (fields.length < 6) {
        print('⚠️ 行${lineNumber + 1}: 必要なフィールドが不足 (${fields.length}/6)');
        return null;
      }

      final name = fields[0].trim();
      final address = fields[1].trim();
      final googleMapsUrl = fields[2].trim();
      final category = fields[3].trim();
      final latStr = fields[4].trim();
      final lngStr = fields[5].trim();

      if (name.isEmpty || latStr.isEmpty || lngStr.isEmpty) {
        print('⚠️ 行${lineNumber + 1}: 必須フィールドが空');
        return null;
      }

      // 緯度・経度をパース
      final latitude = double.tryParse(latStr);
      final longitude = double.tryParse(lngStr);

      if (latitude == null || longitude == null) {
        print('⚠️ 行${lineNumber + 1}: 緯度・経度の形式エラー ($latStr, $lngStr)');
        return null;
      }

      // 有効な座標範囲チェック
      if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        print('⚠️ 行${lineNumber + 1}: 座標が有効範囲外 ($latitude, $longitude)');
        return null;
      }

      return Restaurant(
        id: 'csv_$lineNumber',
        name: name,
        category: category,
        address: address,
        phoneNumber: '', // CSVにないため空
        openingHours: '', // CSVにないため空
        images: [], // CSVにないため空
        description: '$category料理店', // カテゴリから生成
        reviewCount: 0, // CSVにないため0
        distance: 0.0, // 後で計算
        priceRange: '¥¥', // デフォルト値
        latitude: latitude,
        longitude: longitude,
        overallRating: null, // CSVにないためnull
      );
    } catch (e) {
      print('❌ 行${lineNumber + 1}のパースエラー: $e');
      return null;
    }
  }

  /// CSV行をフィールドに分割（ダブルクォート対応）
  static List<String> _parseCsvLine(String line) {
    final List<String> fields = [];
    final buffer = StringBuffer();
    bool insideQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // 最後のフィールドを追加
    fields.add(buffer.toString());
    
    return fields;
  }

  /// カテゴリ別統計を表示
  static void _printCategoryStats(List<Restaurant> restaurants) {
    final categoryCount = <String, int>{};
    
    for (final restaurant in restaurants) {
      final category = restaurant.category.isEmpty ? '未分類' : restaurant.category;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    
    print('📊 カテゴリ別統計:');
    categoryCount.forEach((category, count) {
      print('  $category: $count店舗');
    });
  }

  /// 指定した範囲内のレストランをフィルタリング
  static List<Restaurant> filterRestaurantsByBounds({
    required List<Restaurant> restaurants,
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) {
    return restaurants.where((restaurant) {
      return restaurant.latitude >= minLat &&
             restaurant.latitude <= maxLat &&
             restaurant.longitude >= minLng &&
             restaurant.longitude <= maxLng;
    }).toList();
  }

  /// 東京都心エリア（皇居中心半径10km程度）のレストランのみ取得
  static List<Restaurant> getTokyoCenterRestaurants(List<Restaurant> restaurants) {
    // 東京都心の境界
    const double tokyoCenterLat = 35.6762; // 東京駅
    const double tokyoCenterLng = 139.6503;
    const double boundarySize = 0.1; // 約10km

    return filterRestaurantsByBounds(
      restaurants: restaurants,
      minLat: tokyoCenterLat - boundarySize,
      maxLat: tokyoCenterLat + boundarySize,
      minLng: tokyoCenterLng - boundarySize,
      maxLng: tokyoCenterLng + boundarySize,
    );
  }

  /// 湘南台エリアのレストランのみ取得
  static List<Restaurant> getShonanDaiRestaurants(List<Restaurant> restaurants) {
    // 湘南台の境界
    const double shonanDaiLat = 35.341065; // 湘南台駅
    const double shonanDaiLng = 139.486895;
    const double boundarySize = 0.02; // 約2km

    return filterRestaurantsByBounds(
      restaurants: restaurants,
      minLat: shonanDaiLat - boundarySize,
      maxLat: shonanDaiLat + boundarySize,
      minLng: shonanDaiLng - boundarySize,
      maxLng: shonanDaiLng + boundarySize,
    );
  }

  /// 東京都心以外のレストランのみ取得（湘南台エリアに特化）
  static List<Restaurant> getNonTokyoRestaurants(List<Restaurant> restaurants) {
    return restaurants.where((restaurant) {
      // 東京都心の範囲（皇居中心から半径20km程度）
      const double tokyoCenterLat = 35.6762; // 東京駅
      const double tokyoCenterLng = 139.6503;
      const double tokyoRadius = 0.2; // 約20km
      
      // 東京都心の範囲外であることを確認
      final isOutsideTokyo = (restaurant.latitude < tokyoCenterLat - tokyoRadius ||
                            restaurant.latitude > tokyoCenterLat + tokyoRadius ||
                            restaurant.longitude < tokyoCenterLng - tokyoRadius ||
                            restaurant.longitude > tokyoCenterLng + tokyoRadius);
      
      // 湘南台エリア（神奈川県藤沢市）であることを確認
      final isShonanDaiArea = restaurant.address.contains('神奈川県藤沢市');
      
      return isOutsideTokyo && isShonanDaiArea;
    }).toList();
  }
}