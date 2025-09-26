import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

/// シンプルなGoogle Maps実装
/// 確実に地図背景（道路・地形・ラベル）を表示する
class SimpleGoogleMapsScreen extends StatefulWidget {
  const SimpleGoogleMapsScreen({super.key});

  @override
  State<SimpleGoogleMapsScreen> createState() => _SimpleGoogleMapsScreenState();
}

class _SimpleGoogleMapsScreenState extends State<SimpleGoogleMapsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  List<Restaurant> _restaurants = [];

  // 湘南台駅付近の座標（確実に地図が表示される場所）
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.341065, 139.486895), // 湘南台駅
    zoom: 15.0, // 建物や道が見えるレベル
  );

  @override
  void initState() {
    super.initState();
    _loadRestaurantsAndCreateMarkers();
  }

  /// レストランデータを読み込んでマーカーを作成
  Future<void> _loadRestaurantsAndCreateMarkers() async {
    try {
      print('📍 レストランデータ読み込み開始...');
      final restaurants = await RestaurantService.fetchRestaurantsFromSheet();
      
      setState(() {
        _restaurants = restaurants;
        _createMarkers();
      });
      
      print('✅ ${restaurants.length}件のレストランデータを読み込み完了');
      print('🗺️ ${_markers.length}個のマーカーを作成');
    } catch (e) {
      print('❌ レストランデータの読み込みエラー: $e');
    }
  }

  /// マーカーを作成
  void _createMarkers() {
    _markers.clear();
    
    for (int i = 0; i < _restaurants.length; i++) {
      final restaurant = _restaurants[i];
      
      // 緯度・経度が有効な場合のみマーカーを作成
      if (restaurant.latitude != 0.0 && restaurant.longitude != 0.0) {
        _markers.add(
          Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: '${restaurant.category} • ${restaurant.priceRange}',
              onTap: () => _showRestaurantDetails(restaurant),
            ),
            onTap: () => _onMarkerTapped(restaurant),
            icon: _getMarkerColor(restaurant.category),
          ),
        );
      }
    }
  }

  /// マーカーをタップしたときの処理
  void _onMarkerTapped(Restaurant restaurant) {
    print('📍 マーカータップ: ${restaurant.name} (${restaurant.category})');
    _showRestaurantDetails(restaurant);
  }

  /// 店舗詳細を表示
  void _showRestaurantDetails(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ドラッグハンドル
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 店舗名
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // カテゴリと価格帯
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            restaurant.category,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          restaurant.priceRange,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 評価
                    if (restaurant.overallRating != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.overallRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${restaurant.reviewCount}件のレビュー)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 住所
                    if (restaurant.address.isNotEmpty) ...[
                      const Text(
                        '住所',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 営業時間
                    if (restaurant.openingHours.isNotEmpty) ...[
                      const Text(
                        '営業時間',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.openingHours,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 説明
                    if (restaurant.description.isNotEmpty) ...[
                      const Text(
                        '店舗について',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// カテゴリに応じたマーカーの色を取得
  BitmapDescriptor _getMarkerColor(String category) {
    switch (category) {
      case 'イタリアン':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case '焼肉':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case '寿司':
      case '魚介料理':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case '居酒屋':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case '焼き鳥':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'カフェ':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps - レストラン検索'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GoogleMap(
          // Googleマップ標準表示設定（必須要件）
          mapType: MapType.normal, // Googleマップ標準表示（建物・道・駅・施設名含む）
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            print('✅ Google Maps初期化完了');
          },
          
          // ユーザー操作設定（Googleマップ同様）
          zoomGesturesEnabled: true, // ピンチイン・ピンチアウト操作
          scrollGesturesEnabled: true, // 地図の移動操作
          rotateGesturesEnabled: true, // 地図内の回転操作
          tiltGesturesEnabled: true, // 地図の僾き操作
          
          // 施設名表示のための設定
          buildingsEnabled: true, // 建物名を表示
          mapToolbarEnabled: true, // マップツールバーを有効化
          
          // 現在地設定
          myLocationEnabled: true, // 現在地を表示
          myLocationButtonEnabled: true, // 現在地ボタンを表示
          
          // UIコントロール
          zoomControlsEnabled: false, // ズームボタンは非表示（Googleマップアプリ同様）
          compassEnabled: true, // コンパス表示
          
          // その他の設定
          trafficEnabled: false, // 交通情報は無効
          minMaxZoomPreference: MinMaxZoomPreference.unbounded, // ズーム制限なし
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 地図タイプ切り替えボタン
          FloatingActionButton(
            heroTag: "map_type",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _showMapTypeSelector();
            },
            child: const Icon(Icons.layers, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          
          // レストラン統計表示ボタン
          FloatingActionButton(
            heroTag: "stats",
            backgroundColor: Colors.green,
            onPressed: () {
              _showRestaurantStats();
            },
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  /// 地図タイプ選択ダイアログ
  void _showMapTypeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('地図タイプを選択'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('通常'),
                onTap: () {
                  // MapType.normalに変更するロジックを追加
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('衛星写真'),
                onTap: () {
                  // MapType.satelliteに変更するロジックを追加
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('地形'),
                onTap: () {
                  // MapType.terrainに変更するロジックを追加
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// レストラン統計表示
  void _showRestaurantStats() {
    final categoryCount = <String, int>{};
    for (final restaurant in _restaurants) {
      categoryCount[restaurant.category] = (categoryCount[restaurant.category] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('レストラン統計'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('総店舗数: ${_restaurants.length}店'),
              const SizedBox(height: 12),
              const Text('カテゴリ別:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...categoryCount.entries.map((entry) => 
                Text('${entry.key}: ${entry.value}店')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }
}