import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../constants/app_ikyu_styles.dart';
import '../widgets/airbnb_hero_animation.dart';

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
  final List<Map<String, String>> _allRestaurants = [];
  List<Map<String, String>> _filteredRestaurants = [];
  String? _selectedRestaurantId;
  final List<String> _selectedFilters = [];
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

        // カテゴリ・フィルター処理
        if (_selectedFilters.isNotEmpty) {
          bool matchesFilter = true;
          final category = restaurant['category'] ?? '';
          final name = restaurant['name'] ?? '';
          
          // 現在営業中フィルター（簡易実装 - 実際の営業時間データが必要）
          if (_selectedFilters.contains('filter_open_now')) {
            // TODO: 実際の営業時間データと現在時刻を比較
            matchesFilter = true; // 暫定的に全店舗対象
          }
          
          // 高評価フィルター（簡易実装 - 実際の評価データが必要）
          if (_selectedFilters.contains('filter_high_rating')) {
            // TODO: 実際の評価データを比較
            matchesFilter = true; // 暫定的に全店舗対象
          }
          
          // 肉系カテゴリ
          if (_selectedFilters.contains('category_meat')) {
            matchesFilter = category.contains('焼肉') || category.contains('焼き鳥') || 
                           category.contains('ステーキ') || category.contains('ハンバーグ') ||
                           name.contains('肉') || name.contains('焼肉') || name.contains('焼き鳥');
          }
          
          // 魚系カテゴリ
          if (_selectedFilters.contains('category_seafood')) {
            matchesFilter = category.contains('魚介') || category.contains('寿司') || 
                           category.contains('海鮮') || category.contains('刺身') ||
                           name.contains('魚') || name.contains('寿司') || name.contains('海鮮');
          }
          
          // 麺類カテゴリ
          if (_selectedFilters.contains('category_noodles')) {
            matchesFilter = category.contains('ラーメン') || category.contains('うどん') || 
                           category.contains('そば') || category.contains('パスタ') ||
                           category.contains('イタリアン') ||
                           name.contains('麺') || name.contains('ラーメン') || name.contains('うどん') ||
                           name.contains('そば') || name.contains('パスタ');
          }
          
          // カフェカテゴリ
          if (_selectedFilters.contains('category_cafe')) {
            matchesFilter = category.contains('カフェ') || category.contains('喫茶') || 
                           category.contains('コーヒー') ||
                           name.contains('カフェ') || name.contains('喫茶') || name.contains('コーヒー');
          }
          
          // お手頃フィルター（簡易実装 - 実際の価格データが必要）
          if (_selectedFilters.contains('filter_affordable')) {
            // TODO: 実際の価格データを比較
            matchesFilter = true; // 暫定的に全店舗対象
          }
          
          if (!matchesFilter) return false;
        }

        return true;
      }).toList();
      
      // フィルターされた店舗のマーカーを表示
      _updateMapMarkers();
    });
  }
  
  void _updateMapMarkers() {
    // フィルターが選択されている場合のみマーカーを表示
    if (_selectedFilters.isNotEmpty) {
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

  void _showDetailFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailFilterModal(
        selectedFilters: _selectedFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _selectedFilters.clear();
            _selectedFilters.addAll(filters);
          });
          _applyFiltersAndSearch();
        },
      ),
    );
  }

  void _openRestaurantDetailScreen(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantDetailPageView(
              restaurants: _filteredRestaurants,
              initialIndex: initialIndex,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Airbnb風のスケール＋フェードアニメーション
          const scaleBegin = 0.85;
          const scaleEnd = 1.0;
          const fadeBegin = 0.0;
          const fadeEnd = 1.0;
          const curve = Curves.easeOutCubic;

          var scaleTween = Tween(begin: scaleBegin, end: scaleEnd).chain(
            CurveTween(curve: curve),
          );
          var fadeTween = Tween(begin: fadeBegin, end: fadeEnd).chain(
            CurveTween(curve: curve),
          );

          return ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
                    // 検索バーと詳細フィルター
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 検索バー
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: '検索',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 詳細フィルターアイコン
                          GestureDetector(
                            onTap: _showDetailFilterModal,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: CustomPaint(
                                size: const Size(27, 27),
                                painter: FilterIconPainter(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // フィルタータブ
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('現在営業中', 'filter_open_now'),
                          _buildFilterChip('高評価', 'filter_high_rating'),
                          _buildFilterChip('肉系', 'category_meat'),
                          _buildFilterChip('魚系', 'category_seafood'),
                          _buildFilterChip('麺類', 'category_noodles'),
                          _buildFilterChip('カフェ', 'category_cafe'),
                          _buildFilterChip('お手頃', 'filter_affordable'),
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
                              style: AppIkyuStyles.bodyText,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: AppIkyuStyles.placeholder,
                                prefixIcon: const Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: GestureDetector(
        onTap: () => _onFilterTap(filterId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRestaurantCard(Map<String, String> restaurant) {
    final isSelected = _selectedRestaurantId == restaurant['id'];
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
      child: AirbnbExpandAnimation(
        onTap: () {
          final index = _filteredRestaurants.indexOf(restaurant);
          _openRestaurantDetailScreen(index);
        },
        child: Card(
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isSelected 
                ? BorderSide(color: Colors.blue[300]!, width: 2)
                : BorderSide.none,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
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
                          // 店舗名と評価を同じ行に
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 店舗名
                              Expanded(
                                child: Text(
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
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // 評価とレビュー数
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '4.5',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '(127)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                        ],
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
    // 肉系
    if (category.contains('焼肉') || category.contains('焼き鳥') || category.contains('ステーキ') || category.contains('ハンバーグ')) {
      return Colors.red;
    }
    // 魚系
    if (category.contains('魚介') || category.contains('寿司') || category.contains('海鮮') || category.contains('刺身')) {
      return Colors.blue;
    }
    // 麺類
    if (category.contains('ラーメン') || category.contains('うどん') || category.contains('そば') || category.contains('パスタ') || category.contains('イタリアン')) {
      return Colors.orange;
    }
    // カフェ
    if (category.contains('カフェ') || category.contains('喫茶') || category.contains('コーヒー')) {
      return Colors.brown;
    }
    // 居酒屋
    if (category.contains('居酒屋')) {
      return Colors.green;
    }
    // その他
    return Colors.grey;
  }
  
  IconData _getCategoryIcon(String category) {
    // 肉系
    if (category.contains('焼肉') || category.contains('焼き鳥') || category.contains('ステーキ') || category.contains('ハンバーグ')) {
      return Icons.outdoor_grill;
    }
    // 魚系
    if (category.contains('魚介') || category.contains('寿司') || category.contains('海鮮') || category.contains('刺身')) {
      return Icons.set_meal;
    }
    // 麺類
    if (category.contains('ラーメン') || category.contains('うどん') || category.contains('そば') || category.contains('パスタ')) {
      return Icons.ramen_dining;
    }
    if (category.contains('イタリアン')) {
      return Icons.local_pizza;
    }
    // カフェ
    if (category.contains('カフェ') || category.contains('喫茶') || category.contains('コーヒー')) {
      return Icons.local_cafe;
    }
    // 居酒屋
    if (category.contains('居酒屋')) {
      return Icons.local_bar;
    }
    // その他
    return Icons.restaurant_menu;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// カスタムフィルターアイコンペインター（横棒スタイル）
class FilterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width;
    final double height = size.height;
    
    // 3本の横線を描画
    final double lineSpacing = height / 4;
    final double lineWidth = width * 0.7;
    final double startX = (width - lineWidth) / 2;
    
    for (int i = 0; i < 3; i++) {
      final double y = lineSpacing * (i + 1);
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + lineWidth, y),
        paint,
      );
      
      // 各線に丸いスライダーを描画
      final double circleX = startX + lineWidth * (0.3 + i * 0.2);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(circleX, y), 2.5, paint);
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 詳細フィルターモーダル
class DetailFilterModal extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;

  const DetailFilterModal({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  State<DetailFilterModal> createState() => _DetailFilterModalState();
}

class _DetailFilterModalState extends State<DetailFilterModal> {
  late List<String> _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                const Expanded(
                  child: Text(
                    '詳細フィルター',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // フィルター内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    '営業状況',
                    ['filter_open_now'],
                    ['現在営業中'],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildFilterSection(
                    '評価・価格',
                    ['filter_high_rating', 'filter_affordable'],
                    ['高評価', 'お手頃'],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildFilterSection(
                    'カテゴリ',
                    ['category_meat', 'category_seafood', 'category_noodles', 'category_cafe'],
                    ['肉系', '魚系', '麺類', 'カフェ'],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // 適用ボタン
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFiltersChanged(_tempFilters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '適用 (${_tempFilters.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> filterIds, List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(filterIds.length, (index) {
            final filterId = filterIds[index];
            final label = labels[index];
            final isSelected = _tempFilters.contains(filterId);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _tempFilters.remove(filterId);
                  } else {
                    _tempFilters.add(filterId);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// PageViewを使った店舗詳細画面コンテナ
class RestaurantDetailPageView extends StatefulWidget {
  final List<Map<String, String>> restaurants;
  final int initialIndex;

  const RestaurantDetailPageView({
    super.key,
    required this.restaurants,
    required this.initialIndex,
  });

  @override
  State<RestaurantDetailPageView> createState() => _RestaurantDetailPageViewState();
}

class _RestaurantDetailPageViewState extends State<RestaurantDetailPageView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView for swiping between restaurants
          PageView.builder(
            controller: _pageController,
            itemCount: widget.restaurants.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AirbnbStyleRestaurantDetail(
                restaurant: widget.restaurants[index],
                showBackButton: true,
                onBackPressed: () => Navigator.pop(context),
              );
            },
          ),
          
          // Page indicator
          if (widget.restaurants.length > 1)
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.restaurants.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Google Maps風の店舗詳細画面
class AirbnbStyleRestaurantDetail extends StatefulWidget {
  final Map<String, String> restaurant;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AirbnbStyleRestaurantDetail({
    super.key,
    required this.restaurant,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  State<AirbnbStyleRestaurantDetail> createState() => _AirbnbStyleRestaurantDetailState();
}

class _AirbnbStyleRestaurantDetailState extends State<AirbnbStyleRestaurantDetail> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _isSaved = false;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() {
        _showTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() {
        _showTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ヘッダー画像とアプリバー
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: widget.showBackButton ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
              ),
            ) : null,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? Colors.blue : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSaved = !_isSaved;
                    });
                  },
                ),
              ),
            ],
            title: _showTitle
                ? Text(
                    widget.restaurant['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景画像
                  Container(
                    color: Colors.grey[100],
                    child: Image.network(
                      'https://picsum.photos/400/300?random=${widget.restaurant['id']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '画像を読み込めませんでした',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // グラデーションオーバーレイ
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // コンテンツ
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 店舗名とカテゴリ
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.restaurant['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(widget.restaurant['category'] ?? '').withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.restaurant['category'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getCategoryColor(widget.restaurant['category'] ?? ''),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // アクション用のボタン
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.directions, color: Colors.white, size: 18),
                            label: const Text(
                              'ルート',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call, color: Colors.blue, size: 18),
                            label: const Text(
                              '電話',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Icon(
                            Icons.share,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isSaved = !_isSaved;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: _isSaved ? Colors.blue : Colors.grey[300]!,
                            ),
                          ),
                          child: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: _isSaved ? Colors.blue : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 評価とレビュー
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        const Text(
                          '4.5',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '・',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '127件のレビュー',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // タブバー
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        indicatorColor: Colors.blue,
                        indicatorWeight: 2,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        tabs: const [
                          Tab(text: '情報'),
                          Tab(text: 'メニュー'),
                          Tab(text: 'レビュー'),
                          Tab(text: '写真'),
                          Tab(text: '決済'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // タブコンテンツ
                    Container(
                      height: 600, // 固定の高さを指定
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 店舗情報タブ
                          _buildStoreInfoTab(),
                          // メニュータブ
                          _buildMenuTab(),
                          // レビュータブ
                          _buildReviewTab(),
                          // 写真タブ
                          _buildPhotoTab(),
                          // 決済方法タブ
                          _buildPaymentTab(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String name, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < double.parse(rating) ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 店舗情報タブの内容
  Widget _buildStoreInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 住所
          _buildInfoSection(
            Icons.location_on_outlined,
            '住所',
            widget.restaurant['address'] ?? '',
          ),
          const SizedBox(height: 24),

          // 営業時間
          _buildInfoSection(
            Icons.access_time_outlined,
            '営業時間',
            '11:00 - 22:00 (月-日)',
          ),
          const SizedBox(height: 24),

          // 電話番号
          _buildInfoSection(
            Icons.phone_outlined,
            '電話番号',
            '03-1234-5678',
          ),
          const SizedBox(height: 32),

          // 説明
          const Text(
            '店舗について',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '美味しい料理と心温まるサービスでお客様をお迎えします。新鮮な食材を使用した自慢の料理をぜひお楽しみください。落ち着いた雰囲気の中で、ゆっくりとお食事をお楽しみいただけます。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // メニュータブの内容
  Widget _buildMenuTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'おすすめメニュー',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMenuItem('パスタカルボナーラ', '新鮮な卵とベーコンのクリーミーパスタ', '¥1,200'),
          _buildMenuItem('マルゲリータピザ', 'トマト、モッツァレラ、バジルのクラシック', '¥1,400'),
          _buildMenuItem('シーザーサラダ', 'ロメインレタスとパルメザンチーズ', '¥800'),
          _buildMenuItem('ティラミス', '自家製マスカルポーネチーズ使用', '¥650'),
          _buildMenuItem('ワインセット', '赤・白ワインの飲み比べ', '¥2,800'),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // レビュータブの内容
  Widget _buildReviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'レビュー',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'すべて見る',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildReviewCard('田中太郎', '4.0', '素晴らしいレストランでした！料理も美味しく、スタッフの対応も丁寧でした。また来たいと思います。'),
          const SizedBox(height: 16),
          _buildReviewCard('佐藤花子', '5.0', 'とても美味しい料理でした。特にパスタが絶品でした。雰囲気も良くてデートにぴったりです。'),
          const SizedBox(height: 16),
          _buildReviewCard('鈴木一郎', '4.5', 'サービスも料理も最高でした。特別な日にまた利用したいと思います。'),
          const SizedBox(height: 16),
          _buildReviewCard('高橋美由紀', '3.5', '雰囲気は良かったですが、料理の提供が少し遅かったです。味は美味しかったです。'),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 写真タブの内容
  Widget _buildPhotoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '店舗の写真',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://picsum.photos/120/120?random=${widget.restaurant['id']}_$index',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.photo,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, String description, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 決済方法タブの内容
  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '利用可能な決済方法',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // クレジットカード
          _buildPaymentSection(
            'クレジットカード',
            [
              _buildPaymentItem(Icons.credit_card, 'Visa', '利用可能'),
              _buildPaymentItem(Icons.credit_card, 'Mastercard', '利用可能'),
              _buildPaymentItem(Icons.credit_card, 'JCB', '利用可能'),
              _buildPaymentItem(Icons.credit_card, 'American Express', '利用可能'),
              _buildPaymentItem(Icons.credit_card, 'Diners Club', '利用可能'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 電子マネー
          _buildPaymentSection(
            '電子マネー',
            [
              _buildPaymentItem(Icons.account_balance_wallet, 'PayPay', '利用可能'),
              _buildPaymentItem(Icons.account_balance_wallet, 'LINE Pay', '利用可能'),
              _buildPaymentItem(Icons.account_balance_wallet, 'd払い', '利用可能'),
              _buildPaymentItem(Icons.account_balance_wallet, 'au PAY', '利用可能'),
              _buildPaymentItem(Icons.account_balance_wallet, '楽天Pay', '利用可能'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 交通系ICカード
          _buildPaymentSection(
            '交通系ICカード',
            [
              _buildPaymentItem(Icons.train, 'Suica', '利用可能'),
              _buildPaymentItem(Icons.train, 'PASMO', '利用可能'),
              _buildPaymentItem(Icons.train, 'ICOCA', '利用可能'),
              _buildPaymentItem(Icons.train, 'manaca', '利用可能'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // その他
          _buildPaymentSection(
            'その他',
            [
              _buildPaymentItem(Icons.payments, '現金', '利用可能'),
              _buildPaymentItem(Icons.account_balance, '銀行振込', '一部対応'),
              _buildPaymentItem(Icons.card_giftcard, 'ギフトカード', '利用不可'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 注意事項
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '決済に関する注意事項',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '・ 一部のクレジットカードは最低利用金額があります\n・ 電子マネーの一部はチャージ手数料がかかる場合があります\n・ 決済方法によっては割引が適用される場合があります',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: item,
              )
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(IconData icon, String name, String status) {
    Color statusColor;
    if (status == '利用可能') {
      statusColor = Colors.green;
    } else if (status == '一部対応') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    // 肉系
    if (category.contains('焼肉') || category.contains('焼き鳥') || category.contains('ステーキ') || category.contains('ハンバーグ')) {
      return Colors.red;
    }
    // 魚系
    if (category.contains('魚介') || category.contains('寿司') || category.contains('海鮮') || category.contains('刺身')) {
      return Colors.blue;
    }
    // 麺類
    if (category.contains('ラーメン') || category.contains('うどん') || category.contains('そば') || category.contains('パスタ') || category.contains('イタリアン')) {
      return Colors.orange;
    }
    // カフェ
    if (category.contains('カフェ') || category.contains('喫茶') || category.contains('コーヒー')) {
      return Colors.brown;
    }
    // 居酒屋
    if (category.contains('居酒屋')) {
      return Colors.green;
    }
    // その他
    return Colors.grey;
  }
}