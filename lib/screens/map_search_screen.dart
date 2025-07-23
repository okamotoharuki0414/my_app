import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isMapExpanded = false;
  
  // 店舗データ管理
  List<Map<String, String>> _allRestaurants = [];
  List<Map<String, String>> _filteredRestaurants = [];
  String? _selectedRestaurantId;
  List<String> _selectedFilters = [];
  String _searchQuery = '';
  
  // マーカー表示制御
  Set<Marker> _visibleMarkers = {};
  Set<Marker> _selectedMarkers = {};
  
  // 詳細表示制御
  String? _detailRestaurantId;
  bool _showDetail = false;
  
  // 湘南台駅の位置（デフォルト表示位置）
  static const LatLng _shonanDaiStation = LatLng(35.341065, 139.486895);
  
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _shonanDaiStation,
    zoom: 15.0,
  );
  
  @override
  void initState() {
    super.initState();
    _loadRestaurantsFromCSV();
  }
  
  Future<void> _loadRestaurantsFromCSV() async {
    try {
      final csvData = await rootBundle.loadString('assets/data/restaurant_data.csv');
      final lines = LineSplitter.split(csvData).toList();
      
      final allMarkers = <Marker>{};
      final bounds = <LatLng>[];
      
      // ヘッダー行をスキップして処理
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final fields = _parseCSVLine(line);
        
        if (fields.length >= 7) {
          final id = 'restaurant_$i';
          final name = fields[1].trim();
          final address = fields[2].trim();
          final googleMapUrl = fields[3].trim();
          final category = fields[4].trim();
          final latStr = fields[5].trim();
          final lngStr = fields[6].trim();
          final latitude = double.tryParse(latStr);
          final longitude = double.tryParse(lngStr);
          
          if (latitude != null && longitude != null && name.isNotEmpty) {
            final position = LatLng(latitude, longitude);
            bounds.add(position);
            
            // 店舗データを保存
            final restaurantData = {
              'id': id,
              'name': name,
              'address': address,
              'category': category,
              'googleMapUrl': googleMapUrl,
              'latitude': latStr,
              'longitude': lngStr,
            };
            _allRestaurants.add(restaurantData);
            
            allMarkers.add(
              Marker(
                markerId: MarkerId(id),
                position: position,
                infoWindow: InfoWindow(
                  title: name,
                  snippet: '$category\n$address',
                  onTap: () {
                    print('InfoWindow tapped for $name');
                  },
                ),
                onTap: () {
                  _onRestaurantSelected(id);
                },
              ),
            );
          }
        }
      }
      
      // 初期フィルタリング
      _filteredRestaurants = List.from(_allRestaurants);
      
      setState(() {
        _markers = allMarkers; // 全マーカーを保存
        _visibleMarkers = {}; // 初期状態では表示しない
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onRestaurantSelected(String restaurantId) {
    print('店舗が選択されました: $restaurantId');
    setState(() {
      _selectedRestaurantId = restaurantId;
    });
    
    // マップで選択された店舗の位置にカメラを移動
    final restaurant = _allRestaurants.firstWhere(
      (r) => r['id'] == restaurantId,
      orElse: () => {},
    );
    
    if (restaurant.isNotEmpty) {
      final lat = double.tryParse(restaurant['latitude'] ?? '');
      final lng = double.tryParse(restaurant['longitude'] ?? '');
      
      if (lat != null && lng != null) {
        final position = LatLng(lat, lng);
        
        // 選択された店舗のマーカーのみ表示
        final selectedMarker = _markers.firstWhere(
          (marker) => marker.markerId.value == restaurantId,
          orElse: () => Marker(markerId: MarkerId('empty')),
        );
        
        if (selectedMarker.markerId.value != 'empty') {
          // より詳細なInfoWindowを持つマーカーを作成
          final enhancedMarker = Marker(
            markerId: selectedMarker.markerId,
            position: selectedMarker.position,
            infoWindow: InfoWindow(
              title: restaurant['name'] ?? '',
              snippet: '${restaurant['category'] ?? ''}\n${restaurant['address'] ?? ''}',
              onTap: () {
                print('Enhanced InfoWindow tapped for ${restaurant['name']}');
              },
            ),
            onTap: () {
              _onRestaurantSelected(restaurantId);
            },
          );
          
          setState(() {
            _selectedMarkers = {enhancedMarker};
          });
          
          // マーカーのInfoWindowを表示（少し遅延させる）
          Future.delayed(Duration(milliseconds: 300), () {
            _showMarkerInfoWindow(enhancedMarker);
          });
        }
        
        // カメラを選択された店舗の位置に移動
        _moveCameraToPosition(position);
      }
    }
  }
  
  void _onRestaurantDetailTap(String restaurantId) {
    setState(() {
      if (_detailRestaurantId == restaurantId && _showDetail) {
        // 既に表示中の場合は閉じる
        _showDetail = false;
        _detailRestaurantId = null;
      } else {
        // 新しい詳細を表示
        _detailRestaurantId = restaurantId;
        _showDetail = true;
      }
    });
  }
  
  Future<void> _moveCameraToPosition(LatLng position) async {
    try {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(position, 17.0),
      );
      print('カメラを移動しました: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('カメラ移動エラー: $e');
    }
  }
  
  Future<void> _showMarkerInfoWindow(Marker marker) async {
    try {
      final GoogleMapController controller = await _controller.future;
      await controller.showMarkerInfoWindow(marker.markerId);
    } catch (e) {
      print('InfoWindow表示エラー: $e');
    }
  }
  
  void _applyFiltersAndSearch() {
    setState(() {
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        // 検索クエリフィルター
        final matchesSearch = _searchQuery.isEmpty ||
            (restaurant['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (restaurant['category']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (restaurant['address']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        if (!matchesSearch) return false;

        // カテゴリフィルター
        List<String> categoryFilters = _selectedFilters.where((f) => f.startsWith('category_')).toList();
        if (categoryFilters.isNotEmpty) {
          bool matchesCategory = false;
          final category = restaurant['category'] ?? '';
          if (categoryFilters.contains('category_italian') && category == 'イタリアン') matchesCategory = true;
          if (categoryFilters.contains('category_yakiniku') && category == '焼肉') matchesCategory = true;
          if (categoryFilters.contains('category_seafood') && category == '魚介料理') matchesCategory = true;
          if (categoryFilters.contains('category_sushi') && category == '寿司') matchesCategory = true;
          if (categoryFilters.contains('category_izakaya') && category == '居酒屋') matchesCategory = true;
          if (categoryFilters.contains('category_yakitori') && category == '焼き鳥') matchesCategory = true;
          
          if (!matchesCategory) return false;
        }

        return true;
      }).toList();
      
      // フィルターされた店舗のマーカーを表示
      _updateMapMarkers();
    });
  }
  
  void _updateMapMarkers() {
    // カテゴリフィルターが選択されている場合のみマーカーを表示
    List<String> categoryFilters = _selectedFilters.where((f) => f.startsWith('category_')).toList();
    
    if (categoryFilters.isNotEmpty) {
      // フィルターされた店舗のマーカーを表示
      final filteredMarkers = <Marker>{};
      
      for (final restaurant in _filteredRestaurants) {
        final marker = _markers.firstWhere(
          (m) => m.markerId.value == restaurant['id'],
          orElse: () => Marker(markerId: MarkerId('empty')),
        );
        
        if (marker.markerId.value != 'empty') {
          filteredMarkers.add(marker);
        }
      }
      
      setState(() {
        _visibleMarkers = filteredMarkers;
        _selectedMarkers = {}; // フィルター時は個別選択をクリア
      });
    } else {
      // フィルターが選択されていない場合はマーカーを非表示
      setState(() {
        _visibleMarkers = {};
        _selectedMarkers = {};
      });
    }
  }

  void _onFilterTap(String filterId) {
    setState(() {
      if (_selectedFilters.contains(filterId)) {
        _selectedFilters.remove(filterId);
      } else {
        // 排他的フィルターの処理
        if (filterId.startsWith('sort_')) {
          _selectedFilters.removeWhere((f) => f.startsWith('sort_'));
        }
        _selectedFilters.add(filterId);
      }
    });
    _applyFiltersAndSearch();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }
  
  List<String> _parseCSVLine(String line) {
    final fields = <String>[];
    bool inQuotes = false;
    String currentField = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(currentField);
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    fields.add(currentField);
    return fields;
  }
  
  Future<void> _adjustCameraToFitAllPins(List<LatLng> positions) async {
    if (positions.isEmpty) return;
    
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;
    
    for (final position in positions) {
      minLat = minLat < position.latitude ? minLat : position.latitude;
      maxLat = maxLat > position.latitude ? maxLat : position.latitude;
      minLng = minLng < position.longitude ? minLng : position.longitude;
      maxLng = maxLng > position.longitude ? maxLng : position.longitude;
    }
    
    // 少し余白を追加
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;
    
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
    
    try {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
      print('✅ カメラを全ピンが見える位置に調整しました');
    } catch (e) {
      print('カメラ調整エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 上部エリア（店舗一覧）
          if (!_isMapExpanded)
            Expanded(
              flex: 7,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // ステータスバー対応の余白
                    Container(
                      height: MediaQuery.of(context).padding.top,
                      color: Colors.white,
                    ),
                    // 検索バー
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '店舗名、カテゴリ、住所で検索...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    
                    // フィルタータブ
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('イタリアン', 'category_italian'),
                          _buildFilterChip('焼肉', 'category_yakiniku'),
                          _buildFilterChip('魚介料理', 'category_seafood'),
                          _buildFilterChip('寿司', 'category_sushi'),
                          _buildFilterChip('居酒屋', 'category_izakaya'),
                          _buildFilterChip('焼き鳥', 'category_yakitori'),
                        ],
                      ),
                    ),
                    
                    // 結果数表示
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_filteredRestaurants.length}件の店舗が見つかりました',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // レストランリスト（横スクロール）
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('店舗データを読み込み中...'),
                                ],
                              ),
                            )
                          : _filteredRestaurants.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '条件に一致する店舗が見つかりません',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '検索条件やフィルターを変更してみてください',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _filteredRestaurants.length,
                                  itemBuilder: (context, index) {
                                    final restaurant = _filteredRestaurants[index];
                                    return _buildRestaurantCard(restaurant);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          
          // マップエリア
          Expanded(
            flex: _isMapExpanded ? 10 : 3,
            child: GestureDetector(
              onPanUpdate: (details) {
                // スワイプジェスチャーを検出（閾値を上げて誤動作を防ぐ）
                if (_isMapExpanded) {
                  // 拡大状態で下方向スワイプでマップを閉じる
                  if (details.delta.dy > 8) {
                    setState(() {
                      _isMapExpanded = false;
                    });
                  }
                } else {
                  // 縮小状態で上方向スワイプでマップを開く  
                  if (details.delta.dy < -8) {
                    setState(() {
                      _isMapExpanded = true;
                    });
                  }
                }
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: _isMapExpanded 
                    ? BorderRadius.zero 
                    : const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                  boxShadow: _isMapExpanded 
                    ? [] 
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                ),
                child: ClipRRect(
                  borderRadius: _isMapExpanded 
                    ? BorderRadius.zero 
                    : const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                  child: Stack(
                    children: [
                      // Google Maps
                      GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) {
                            _controller.complete(controller);
                          }
                        },
                        initialCameraPosition: _initialCameraPosition,
                        markers: _visibleMarkers.union(_selectedMarkers),
                        mapType: MapType.normal,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: _isMapExpanded,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: _isMapExpanded,
                        tiltGesturesEnabled: _isMapExpanded,
                        buildingsEnabled: true,
                        mapToolbarEnabled: _isMapExpanded,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: _isMapExpanded,
                        minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                      ),
                      
                      // 検索バー（拡大時のみ表示）
                      if (_isMapExpanded)
                        Positioned(
                          top: 55,
                          left: 16,
                          right: 70,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      
                      // 戻るボタン（拡大時のみ表示）
                      if (_isMapExpanded)
                        Positioned(
                          top: 55,
                          right: 16,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black87),
                              onPressed: () {
                                setState(() {
                                  _isMapExpanded = false;
                                });
                              },
                            ),
                          ),
                        ),
                      
                      // マップ縮小案内（拡大時のみ表示）
                      if (_isMapExpanded)
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                                  Text(
                                    '下にスワイプして縮小',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // マップ拡大・縮小インジケーター
                      if (!_isMapExpanded)
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 16),
                                  Text(
                                    '上にスワイプして拡大',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 詳細パネル
          if (_showDetail && _detailRestaurantId != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDetailPanel(_detailRestaurantId!),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailPanel(String restaurantId) {
    final restaurant = _allRestaurants.firstWhere(
      (r) => r['id'] == restaurantId,
      orElse: () => {},
    );
    
    if (restaurant.isEmpty) return SizedBox.shrink();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ハンドル
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // ヘッダー
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(restaurant['category'] ?? '').withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          restaurant['category'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getCategoryColor(restaurant['category'] ?? ''),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDetail = false;
                      _detailRestaurantId = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 詳細情報
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 住所
                  _buildDetailRow(
                    Icons.location_on,
                    '住所',
                    restaurant['address'] ?? '',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google マップリンク
                  _buildDetailRow(
                    Icons.map,
                    'Google マップ',
                    'マップで開く',
                    onTap: () {
                      // Google マップを開く処理
                      print('Google マップを開く: ${restaurant['googleMapUrl']}');
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 座標情報
                  _buildDetailRow(
                    Icons.gps_fixed,
                    '座標',
                    '緯度: ${restaurant['latitude']}, 経度: ${restaurant['longitude']}',
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String title, String content, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String filterId) {
    final isSelected = _selectedFilters.contains(filterId);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _onFilterTap(filterId),
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildRestaurantCard(Map<String, String> restaurant) {
    final isSelected = _selectedRestaurantId == restaurant['id'];
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
      child: Card(
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected 
            ? BorderSide(color: Colors.blue[300]!, width: 2)
            : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            _onRestaurantSelected(restaurant['id'] ?? '');
          },
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              child: Stack(
                children: [
                  // 背景画像（プレースホルダー）
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(restaurant['category'] ?? '').withValues(alpha: 0.7),
                            _getCategoryColor(restaurant['category'] ?? '').withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                      child: Image.network(
                        'https://via.placeholder.com/280x200?text=${Uri.encodeComponent(restaurant['name'] ?? '')}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getCategoryColor(restaurant['category'] ?? '').withValues(alpha: 0.7),
                                  _getCategoryColor(restaurant['category'] ?? '').withValues(alpha: 0.9),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // ぼかしオーバーレイ
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 店舗情報オーバーレイ
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 店舗名
                          Text(
                            restaurant['name'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // カテゴリ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              restaurant['category'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(restaurant['category'] ?? ''),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 住所
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  restaurant['address'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 詳細ボタン
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _onRestaurantDetailTap(restaurant['id'] ?? ''),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[600]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '詳細',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 選択インジケーター
                  if (isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'イタリアン':
        return Colors.orange;
      case '焼肉':
        return Colors.red;
      case '魚介料理':
        return Colors.blue;
      case '寿司':
        return Colors.indigo;
      case '居酒屋':
        return Colors.green;
      case '焼き鳥':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'イタリアン':
        return Icons.local_pizza;
      case '焼肉':
        return Icons.outdoor_grill;
      case '魚介料理':
        return Icons.set_meal;
      case '寿司':
        return Icons.restaurant;
      case '居酒屋':
        return Icons.local_bar;
      case '焼き鳥':
        return Icons.kebab_dining;
      default:
        return Icons.restaurant_menu;
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}