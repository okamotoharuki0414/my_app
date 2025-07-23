import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 CSVデータテスト開始...');
  
  // CSVファイルを読み込み
  final file = File('/Users/okamotoharuakira/development/my_app/assets/data/restaurants_new.csv');
  if (!file.existsSync()) {
    print('❌ CSVファイルが見つかりません: ${file.path}');
    return;
  }
  
  final csvData = await file.readAsString();
  final lines = csvData.split('\n');
  
  print('📊 CSVファイル詳細:');
  print('   ファイルサイズ: ${csvData.length} 文字');
  print('   総行数: ${lines.length}');
  print('   ヘッダー: ${lines[0]}');
  print('   データ行数: ${lines.length - 1}');
  
  // 各行の解析
  int validRows = 0;
  int emptyRows = 0;
  final categories = <String, int>{};
  
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) {
      emptyRows++;
      continue;
    }
    
    final columns = _parseCsvLine(line);
    if (columns.length >= 2) {
      validRows++;
      final storeName = columns.length > 1 ? columns[1].trim() : '';
      final category = columns.length > 4 ? columns[4].trim() : '';
      
      if (category.isNotEmpty) {
        categories[category] = (categories[category] ?? 0) + 1;
      }
      
      // 最初の10店舗と最後の5店舗を表示
      if (i <= 10 || i > lines.length - 6) {
        print('   行$i: $storeName (${category.isEmpty ? '未分類' : category})');
      } else if (i == 11) {
        print('   ...');
      }
    }
  }
  
  print('📊 解析結果:');
  print('   有効な店舗データ: $validRows件');
  print('   空行: $emptyRows件');
  print('   カテゴリ別統計:');
  categories.entries.forEach((entry) {
    print('     ${entry.key}: ${entry.value}件');
  });
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
  
  result.add(current); // 最後の列を追加
  return result;
}