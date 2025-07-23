import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class CsvParserService {
  /// 新しいGoogleスプレッドシートのCSV形式からレストランデータを読み取る
  /// 
  /// CSV形式：
  /// 店舗ID,店舗名,住所,Googleマップ,カテゴリ１,カテゴリ２
  static Future<List<Restaurant>> parseRestaurantsFromNewCsv() async {
    try {
      print('📄 新しいCSVフォーマットからデータを読み込み開始...');
      
      // まずローカルアセットから試行
      final csvData = await rootBundle.loadString('assets/data/restaurants_new.csv');
      return _parseNewCsvData(csvData);
      
    } catch (assetError) {
      print('❌ ローカルアセット読み込みエラー: $assetError');
      
      try {
        // ネットワークから直接取得
        print('🌐 ネットワークからCSVデータを取得...');
        final response = await http.get(
          Uri.parse('https://docs.google.com/spreadsheets/d/1ryld0XXkG02wC2-SpWwYLgvGGsNcJaYgpE_kGOS-aHw/export?format=csv'),
          headers: {'User-Agent': 'Flutter-App/1.0'},
        ).timeout(const Duration(seconds: 15));
        
        if (response.statusCode == 200) {
          final csvData = utf8.decode(response.bodyBytes);
          return _parseNewCsvData(csvData);
        } else {
          throw Exception('HTTP Error ${response.statusCode}');
        }
      } catch (networkError) {
        print('❌ ネットワーク読み込みエラー: $networkError');
        return [];
      }
    }
  }
  
  static List<Restaurant> _parseNewCsvData(String csvData) {
    final restaurants = <Restaurant>[];
    final lines = csvData.split('\n');
    
    if (lines.isEmpty) {
      print('❌ CSVデータが空です');
      return restaurants;
    }
    
    // ヘッダー行を確認
    final headerLine = lines[0].trim();
    print('📋 ヘッダー行: $headerLine');
    
    // 期待されるヘッダー形式をチェック
    final expectedColumns = ['店舗ID', '店舗名', '住所', 'Googleマップ', 'カテゴリ１', 'カテゴリ２'];
    final headerColumns = _parseCsvLine(headerLine);
    
    print('📊 検出された列数: ${headerColumns.length}');
    print('📊 期待される列: $expectedColumns');
    print('📊 実際の列: $headerColumns');
    print('📊 CSVの行数（ヘッダー含む）: ${lines.length}');
    print('📊 処理対象データ行数: ${lines.length - 1}');
    
    int restaurantIdCounter = 1;
    
    // データ行を処理（1行目はヘッダーなのでスキップ）
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final columns = _parseCsvLine(line);
      if (columns.length < 2) {
        print('⚠️ 行 $i スキップ（列数不足）: $line');
        continue;
      }
      
      final name = columns.length > 1 ? columns[1].trim() : '';
      if (name.isEmpty) {
        print('⚠️ 行 $i スキップ（店舗名なし）: $line');
        continue;
      }
      
      try {
        // CSVの構造に基づいてレストランオブジェクトを作成
        final restaurantId = columns.isNotEmpty && columns[0].trim().isNotEmpty 
            ? columns[0].trim() 
            : 'rest_${restaurantIdCounter.toString().padLeft(3, '0')}';
        
        final address = columns.length > 2 ? columns[2].trim() : '';
        final googleMapsUrl = columns.length > 3 ? columns[3].trim() : '';
        final category1 = columns.length > 4 ? columns[4].trim() : '';
        final category2 = columns.length > 5 ? columns[5].trim() : '';
        
        // メインカテゴリを決定（カテゴリ１を優先、空の場合はカテゴリ２）
        final mainCategory = category1.isNotEmpty ? category1 : category2;
        
        // 湘南台エリアのデフォルト座標（分散配置用）
        final baseLatitude = 35.3394;
        final baseLongitude = 139.4869;
        final latitudeOffset = (i % 10 - 5) * 0.002; // -0.01 to 0.01度の範囲
        final longitudeOffset = (i % 8 - 4) * 0.003; // -0.012 to 0.012度の範囲
        
        final restaurant = Restaurant(
          id: restaurantId,
          name: name,
          address: address,
          category: mainCategory,
          latitude: baseLatitude + latitudeOffset,
          longitude: baseLongitude + longitudeOffset,
          overallRating: 4.0 + (i % 5) * 0.2, // 4.0-4.8の範囲でランダム
          priceRange: _getPriceRangeByCategory(mainCategory),
          images: [],
          phoneNumber: '',
          openingHours: '11:00-22:00', // デフォルト営業時間
          description: '${mainCategory.isNotEmpty ? mainCategory : ''}の人気店です。',
          reviewCount: 50 + (i % 100),
          distance: 0.5 + (i % 20) * 0.1, // 0.5-2.5kmの範囲
        );
        
        restaurants.add(restaurant);
        restaurantIdCounter++;
        
        if (restaurantIdCounter <= 10 || restaurantIdCounter % 10 == 0) {
          print('🏪 レストラン追加 [$restaurantIdCounter]: ${restaurant.name} (${restaurant.category})');
        }
        
      } catch (e) {
        print('⚠️ 行 $i のパースエラー: $e');
        print('📄 問題のある行: $line');
      }
    }
    
    print('✅ 新しいCSVから ${restaurants.length} 件のレストランを読み込み完了');
    
    // カテゴリ別の統計を表示
    final categoryStats = <String, int>{};
    for (final restaurant in restaurants) {
      final category = restaurant.category.isNotEmpty ? restaurant.category : '未分類';
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }
    
    print('📊 カテゴリ別統計:');
    categoryStats.forEach((category, count) {
      print('   $category: $count件');
    });
    
    return restaurants;
  }
  
  /// カテゴリに基づいて価格帯を決定
  static String _getPriceRangeByCategory(String category) {
    switch (category.toLowerCase()) {
      case '寿司':
      case '焼肉':
        return '¥¥¥';
      case '居酒屋':
      case '焼き鳥':
        return '¥¥';
      case 'イタリアン':
      case '魚介料理':
        return '¥¥¥';
      case 'カフェ':
        return '¥¥';
      default:
        return '¥¥';
    }
  }
  
  /// 簡単なCSVパーサー（カンマ区切り、ダブルクォート対応）
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var inQuotes = false;
    var current = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    
    result.add(current); // 最後の列を追加
    return result;
  }
}