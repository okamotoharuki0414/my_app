import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  // Google Geocoding APIキー（あなたのAPIキーを使用）
  static const String _apiKey = 'AIzaSyARwqfqjYHsQL7gX3ze57vbx24kcuyyY-w';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  // 住所を緯度経度に変換
  static Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      print('🗺️ Geocoding開始: $address');
      
      // 住所をクリーンアップ（不要な文字を削除）
      final cleanAddress = _cleanAddress(address);
      print('🧹 クリーンアップ後の住所: $cleanAddress');
      
      final url = Uri.parse('$_baseUrl?address=${Uri.encodeComponent(cleanAddress)}&key=$_apiKey&language=ja&region=jp');
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'].toDouble();
          final lng = location['lng'].toDouble();
          
          print('✅ Geocoding成功: $lat, $lng');
          return {'latitude': lat, 'longitude': lng};
        } else {
          print('❌ Geocoding失敗: ${data['status']}');
          return null;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Geocoding例外: $e');
      return null;
    }
  }

  // 住所をクリーンアップ（Geocoding精度向上のため）
  static String _cleanAddress(String address) {
    String cleaned = address;
    
    // 郵便番号の後にスペースを追加
    cleaned = cleaned.replaceAllMapped(RegExp(r'〒(\d{3}-\d{4})'), (match) => '〒${match.group(1)} ');
    
    // 建物名やフロア情報を削除（Geocodingの精度向上のため）
    cleaned = cleaned.replaceAll(RegExp(r'\s+[0-9０-９]+[FfＦｆ階]\s*'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[A-Za-z０-９\s]+ビル.*'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[A-Za-z０-９\s]+マンション.*'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[0-9０-９]+号.*'), ' ');
    
    // 余分なスペースを削除
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  // 複数の住所を一括でGeocoding（効率化のため）
  static Future<Map<String, Map<String, double>>> batchGeocode(List<String> addresses) async {
    final results = <String, Map<String, double>>{};
    
    print('🗺️ 一括Geocoding開始: ${addresses.length}件');
    
    for (int i = 0; i < addresses.length; i++) {
      final address = addresses[i];
      
      // APIレート制限を避けるため少し待機
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      final location = await geocodeAddress(address);
      if (location != null) {
        results[address] = location;
      }
      
      // 進捗表示
      if ((i + 1) % 10 == 0 || i == addresses.length - 1) {
        print('📍 Geocoding進捗: ${i + 1}/${addresses.length}');
      }
    }
    
    print('✅ 一括Geocoding完了: ${results.length}/${addresses.length}件成功');
    return results;
  }
}