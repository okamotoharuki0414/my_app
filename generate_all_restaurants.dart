import 'dart:io';

void main() async {
  print('🏭 全店舗データの生成開始...');
  
  // CSVファイルを読み込み
  final file = File('/Users/okamotoharuakira/development/my_app/assets/data/restaurants_new.csv');
  if (!file.existsSync()) {
    print('❌ CSVファイルが見つかりません: ${file.path}');
    return;
  }
  
  final csvData = await file.readAsString();
  final lines = csvData.split('\n');
  
  print('📊 処理開始: ${lines.length}行 (${lines.length - 1}店舗)');
  
  final dartCode = StringBuffer();
  dartCode.writeln("import '../models/restaurant.dart';");
  dartCode.writeln("");
  dartCode.writeln("/// Googleスプレッドシートから取得した湘南台エリアのレストランデータ");
  dartCode.writeln("/// 全${lines.length - 1}店舗を含む完全版");
  dartCode.writeln("class RestaurantDataComplete {");
  dartCode.writeln("  static List<Restaurant> getRestaurantsFromSpreadsheet() {");
  dartCode.writeln("    return [");
  
  // データ行を処理
  int restaurantIdCounter = 1;
  int processedCount = 0;
  
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    
    final columns = _parseCsvLine(line);
    if (columns.length < 2) continue;
    
    final name = columns.length > 1 ? columns[1].trim() : '';
    if (name.isEmpty) continue;
    
    final restaurantId = 'rest_${restaurantIdCounter.toString().padLeft(3, '0')}';
    final address = columns.length > 2 ? columns[2].trim() : '';
    final category1 = columns.length > 4 ? columns[4].trim() : '';
    final category2 = columns.length > 5 ? columns[5].trim() : '';
    final mainCategory = category1.isNotEmpty ? category1 : category2;
    
    // 基本座標（湘南台駅）
    final baseLatitude = 35.341065;
    final baseLongitude = 139.486895;
    final latitudeOffset = (restaurantIdCounter % 10 - 5) * 0.002;
    final longitudeOffset = (restaurantIdCounter % 8 - 4) * 0.003;
    
    final priceRange = _getPriceRangeByCategory(mainCategory);
    final rating = 4.0 + (restaurantIdCounter % 5) * 0.2;
    final reviewCount = 50 + (restaurantIdCounter % 100);
    final distance = 0.5 + (restaurantIdCounter % 20) * 0.1;
    
    dartCode.writeln("      Restaurant(");
    dartCode.writeln("        id: '$restaurantId',");
    dartCode.writeln("        name: '${_escapeString(name)}',");
    dartCode.writeln("        address: '${_escapeString(address)}',");
    dartCode.writeln("        category: '${_escapeString(mainCategory)}',");
    dartCode.writeln("        latitude: ${baseLatitude + latitudeOffset},");
    dartCode.writeln("        longitude: ${baseLongitude + longitudeOffset},");
    dartCode.writeln("        overallRating: $rating,");
    dartCode.writeln("        priceRange: '$priceRange',");
    dartCode.writeln("        images: [],");
    dartCode.writeln("        phoneNumber: '',");
    dartCode.writeln("        openingHours: '11:00-22:00',");
    dartCode.writeln("        description: '${_escapeString(mainCategory)}の人気店です。',");
    dartCode.writeln("        reviewCount: $reviewCount,");
    dartCode.writeln("        distance: $distance,");
    dartCode.writeln("      ),");
    
    restaurantIdCounter++;
    processedCount++;
    
    if (processedCount % 10 == 0 || processedCount <= 10) {
      print('✅ 処理完了: $processedCount/$processedCount - $name ($mainCategory)');
    }
  }
  
  dartCode.writeln("    ];");
  dartCode.writeln("  }");
  dartCode.writeln("");
  dartCode.writeln("  /// カテゴリ別の統計情報");
  dartCode.writeln("  static Map<String, int> getCategoryStats() {");
  dartCode.writeln("    final restaurants = getRestaurantsFromSpreadsheet();");
  dartCode.writeln("    final stats = <String, int>{};");
  dartCode.writeln("    ");
  dartCode.writeln("    for (final restaurant in restaurants) {");
  dartCode.writeln("      final category = restaurant.category.isNotEmpty ? restaurant.category : '未分類';");
  dartCode.writeln("      stats[category] = (stats[category] ?? 0) + 1;");
  dartCode.writeln("    }");
  dartCode.writeln("    ");
  dartCode.writeln("    return stats;");
  dartCode.writeln("  }");
  dartCode.writeln("");
  dartCode.writeln("  /// 全レストラン数");
  dartCode.writeln("  static int getTotalCount() {");
  dartCode.writeln("    return getRestaurantsFromSpreadsheet().length;");
  dartCode.writeln("  }");
  dartCode.writeln("}");
  
  // ファイルに書き込み
  final outputFile = File('/Users/okamotoharuakira/development/my_app/lib/data/restaurant_data_complete.dart');
  await outputFile.writeAsString(dartCode.toString());
  
  print('🎯 完了: $processedCount店舗を処理');
  print('📁 出力ファイル: ${outputFile.path}');
}

List<String> _parseCsvLine(String line) {
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
  
  result.add(current);
  return result;
}

String _getPriceRangeByCategory(String category) {
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

String _escapeString(String input) {
  return input.replaceAll("'", "\\'").replaceAll('\n', '\\n');
}