import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UrlCoordinateService {
  /// Google Mapsの短縮URLから緯度経度を取得する
  static Future<LatLng?> getLatLngFromGoogleMapsUrl(String url) async {
    if (url.isEmpty) return null;
    
    try {
      print('🗺️ URL座標取得開始: $url');
      
      // 1. 短縮URLにリクエストを送り、リダイレクト先のURLを取得
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = false;
      
      final response = await http.Client().send(request);
      
      // 'location'ヘッダーにリダイレクト先のURLが含まれている
      String? redirectedUrl = response.headers['location'];

      // 複数回のリダイレクトに対応
      int redirectCount = 0;
      while (redirectedUrl != null && redirectCount < 5) {
        print('📍 リダイレクト先: $redirectedUrl');
        
        try {
          final redirectRequest = http.Request('GET', Uri.parse(redirectedUrl))
            ..followRedirects = false;
          final redirectResponse = await http.Client().send(redirectRequest);
          
          if (redirectResponse.statusCode == 200) {
            // 最終的なURLに到達
            break;
          }
          
          redirectedUrl = redirectResponse.headers['location'];
          redirectCount++;
        } catch (e) {
          print('⚠️ リダイレクト処理エラー: $e');
          break;
        }
      }

      if (redirectedUrl == null) {
        print('❌ リダイレクト先が見つかりませんでした');
        return null;
      }

      // 2. 取得したURLから正規表現で座標を抽出
      // URLの例: https://www.google.com/maps/place/.../@35.681236,139.767125,15z/...
      final patterns = [
        RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)'), // 標準的なパターン
        RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)'), // 別のパターン
        RegExp(r'll=(-?\d+\.\d+),(-?\d+\.\d+)'), // さらに別のパターン
      ];

      for (final regExp in patterns) {
        final match = regExp.firstMatch(redirectedUrl);
        if (match != null && match.groupCount >= 2) {
          final lat = double.tryParse(match.group(1)!);
          final lng = double.tryParse(match.group(2)!);
          
          if (lat != null && lng != null) {
            print('✅ 座標抽出成功: ($lat, $lng)');
            return LatLng(lat, lng);
          }
        }
      }

      print('❌ URLから座標を抽出できませんでした: $redirectedUrl');
      return null;
      
    } catch (e) {
      print('❌ URLの解決中にエラーが発生: $e');
      return null;
    }
  }

  /// 複数のURLから座標を一括取得（進捗表示付き）
  static Future<Map<String, LatLng>> getBatchCoordinatesFromUrls(
    Map<String, String> urlMap, {
    Function(int processed, int total)? onProgress,
  }) async {
    final result = <String, LatLng>{};
    int processed = 0;
    
    for (final entry in urlMap.entries) {
      final key = entry.key;
      final url = entry.value;
      
      final latLng = await getLatLngFromGoogleMapsUrl(url);
      if (latLng != null) {
        result[key] = latLng;
      }
      
      processed++;
      onProgress?.call(processed, urlMap.length);
      
      // APIを適度な間隔で呼び出す（レート制限対策）
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return result;
  }
}