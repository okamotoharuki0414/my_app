import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';
import '../services/csv_restaurant_service.dart';

/// CSVファイルからレストランデータを読み込んでGoogle Mapsに表示
/// 東京都心を中心とした地図表示
class CsvGoogleMapsScreen extends StatefulWidget {
  const CsvGoogleMapsScreen({super.key});

  @override
  State<CsvGoogleMapsScreen> createState() => _CsvGoogleMapsScreenState();
}

class _CsvGoogleMapsScreenState extends State<CsvGoogleMapsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  
  // 湘南台駅を中心とした初期位置（建物や道路が見えるレベル）
  static const LatLng _shonanDaiStation = LatLng(35.341065, 139.486895);
  
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _shonanDaiStation,
    zoom: 15.0, // 建物や道が見えるレベル
  );

  final Set<Marker> _markers = {};
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _displayRestaurants = [];
  bool _isLoading = true;
  bool _mapReady = false;
  String _filterArea = 'all'; // all, tokyo, shonanDai

  @override
  void initState() {
    super.initState();
    _loadRestaurantsFromCsv();
  }

  /// CSVファイルからレストランデータを読み込み
  Future<void> _loadRestaurantsFromCsv() async {
    try {
      developer.log('📄 CSVからレストランデータ読み込み開始...');
      
      final restaurants = await CsvRestaurantService.loadRestaurantsFromCsv();
      
      setState(() {
        _allRestaurants = restaurants;
        _displayRestaurants = restaurants;
        _isLoading = false;
      });
      
      _createMarkersFromRestaurants();
      developer.log('✅ ${restaurants.length}店舗のデータを読み込み完了');
      
    } catch (e) {
      developer.log('❌ CSVデータ読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// レストランデータからマーカーを作成
  void _createMarkersFromRestaurants() {
    _markers.clear();
    
    for (int i = 0; i < _displayRestaurants.length; i++) {
      final restaurant = _displayRestaurants[i];
      
      _markers.add(
        Marker(
          markerId: MarkerId(restaurant.id),
          position: LatLng(restaurant.latitude, restaurant.longitude),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: '${restaurant.category} • ${restaurant.address}',
            onTap: () => _showRestaurantDetails(restaurant),
          ),
          onTap: () => _onMarkerTapped(restaurant),
          icon: _getMarkerIcon(restaurant.category),
        ),
      );
    }
    
    developer.log('🗺️ ${_markers.length}個のマーカーを作成');
    if (mounted) {
      setState(() {});
    }
  }

  /// マーカータップ時の処理
  void _onMarkerTapped(Restaurant restaurant) {
    developer.log('📍 マーカータップ: ${restaurant.name}');
    _showRestaurantDetails(restaurant);
  }

  /// カテゴリに応じたマーカーアイコン
  BitmapDescriptor _getMarkerIcon(String category) {
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
      case '日本料理':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'カフェ':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  /// Google Map作成コールバック
  void _onMapCreated(GoogleMapController controller) async {
    try {
      _mapController = controller;
      _controller.complete(controller);
      
      setState(() {
        _mapReady = true;
      });
      
      developer.log('✅ Google Map初期化完了');
      
    } catch (e) {
      developer.log('❌ Google Map初期化エラー: $e');
    }
  }

  /// エリアフィルタリング
  void _filterByArea(String area) {
    setState(() {
      _filterArea = area;
      switch (area) {
        case 'tokyo':
          _displayRestaurants = CsvRestaurantService.getTokyoCenterRestaurants(_allRestaurants);
          break;
        case 'shonanDai':
          _displayRestaurants = CsvRestaurantService.getShonanDaiRestaurants(_allRestaurants);
          break;
        default:
          _displayRestaurants = _allRestaurants;
          break;
      }
    });
    
    _createMarkersFromRestaurants();
    developer.log('🔍 エリアフィルター: $area -> ${_displayRestaurants.length}店舗');
  }

  /// 指定エリアに地図を移動
  Future<void> _moveToArea(String area) async {
    if (_mapController == null) return;

    CameraPosition targetPosition;
    switch (area) {
      case 'tokyo':
        targetPosition = const CameraPosition(
          target: LatLng(35.6762, 139.6503), // 東京駅
          zoom: 15.0,
        );
        break;
      case 'shonanDai':
        targetPosition = const CameraPosition(
          target: _shonanDaiStation, // 湘南台駅
          zoom: 15.0,
        );
        break;
      default:
        targetPosition = const CameraPosition(
          target: _shonanDaiStation,
          zoom: 15.0,
        );
        break;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(targetPosition),
    );
  }

  /// 店舗詳細表示
  void _showRestaurantDetails(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // カテゴリ
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
                  const SizedBox(height: 16),
                  
                  // 住所
                  if (restaurant.address.isNotEmpty) ...[
                    const Text(
                      '住所',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(restaurant.address),
                    const SizedBox(height: 16),
                  ],
                  
                  // 座標情報
                  const Text(
                    '位置情報',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('緯度: ${restaurant.latitude.toStringAsFixed(6)}'),
                  Text('経度: ${restaurant.longitude.toStringAsFixed(6)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Google Maps'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_mapReady)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.hourglass_empty, color: Colors.white),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps（画面全体に表示）
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              // Googleマップ標準表示設定（必須要件）
              mapType: MapType.normal, // Googleマップ標準表示（建物・道・駅・施設名含む）
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
              
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
          
          // ローディング表示
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.orange),
                      SizedBox(height: 16),
                      Text('CSVデータを読み込み中...'),
                    ],
                  ),
                ),
              ),
            ),
          
          // エリアフィルター
          if (!_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'エリア選択 (${_displayRestaurants.length}店舗)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFilterButton('全エリア', 'all'),
                          _buildFilterButton('東京都心', 'tokyo'),
                          _buildFilterButton('湘南台', 'shonanDai'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveToArea(_filterArea);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterButton(String label, String area) {
    final isSelected = _filterArea == area;
    return ElevatedButton(
      onPressed: () {
        _filterByArea(area);
        _moveToArea(area);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}