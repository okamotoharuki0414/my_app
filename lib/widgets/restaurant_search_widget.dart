import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';

class RestaurantSearchWidget extends StatefulWidget {
  final Function(Restaurant) onRestaurantSelected;

  const RestaurantSearchWidget({
    super.key,
    required this.onRestaurantSelected,
  });

  @override
  State<RestaurantSearchWidget> createState() => _RestaurantSearchWidgetState();
}

class _RestaurantSearchWidgetState extends State<RestaurantSearchWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _searchResults = [];
  bool _isSearching = false;
  late TabController _tabController;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Restaurant? _selectedMapRestaurant;

  // サンプルレストランデータ
  final List<Restaurant> _allRestaurants = [
    Restaurant(
      id: 'rest1',
      name: 'リストランテ ベッラヴィスタ',
      category: 'イタリアン',
      overallRating: 4.5,
      address: '東京都渋谷区神宮前1-2-3',
      phoneNumber: '03-1234-5678',
      openingHours: '11:30-14:30, 18:00-22:00',
      images: ['https://placehold.co/300x200'],
      description: '本格的なイタリア料理を楽しめる高級レストランです。',
      reviewCount: 128,
      distance: 0.8,
      priceRange: '¥¥¥',
      latitude: 35.6762,
      longitude: 139.6503,
    ),
    Restaurant(
      id: 'rest2',
      name: '懐石料理 山田',
      category: '日本料理',
      overallRating: 4.8,
      address: '東京都新宿区歌舞伎町2-1-5',
      phoneNumber: '03-5678-9012',
      openingHours: '17:00-23:00 (日曜定休)',
      images: ['https://placehold.co/300x200'],
      description: '伝統的な日本料理を現代風にアレンジした懐石料理店です。',
      reviewCount: 95,
      distance: 1.2,
      priceRange: '¥¥¥¥',
      latitude: 35.6719,
      longitude: 139.7655,
    ),
    Restaurant(
      id: 'rest3',
      name: 'カフィ アオゾラ',
      category: 'カフェ',
      overallRating: 4.2,
      address: '東京都新宿区新宿3-15-8',
      phoneNumber: '03-2345-6789',
      openingHours: '8:00-20:00',
      images: ['https://placehold.co/300x200'],
      description: '落ち着いた雰囲気で仕事や勉強に集中できるカフェです。',
      reviewCount: 67,
      distance: 2.1,
      priceRange: '¥¥',
      latitude: 35.6896,
      longitude: 139.7006,
    ),
    Restaurant(
      id: 'rest4',
      name: '博多一風堂',
      category: 'ラーメン',
      overallRating: 4.6,
      address: '福岡県福岡市博多区中洲川端町5-7-1',
      phoneNumber: '092-1234-5678',
      openingHours: '11:00-15:00, 18:00-23:00',
      images: ['https://placehold.co/300x200'],
      description: '本場博多ラーメンの老舗。濃厚な豚骨スープが自慢です。',
      reviewCount: 203,
      distance: 3.5,
      priceRange: '¥',
      latitude: 35.7148,
      longitude: 139.7967,
    ),
    Restaurant(
      id: 'rest5',
      name: 'ビストロ ラ ヴィーニュ',
      category: 'フレンチ',
      overallRating: 4.4,
      address: '東京都渋谷区渋谷2-8-12',
      phoneNumber: '03-3456-7890',
      openingHours: '18:00-24:00 (月曜定休)',
      images: ['https://placehold.co/300x200'],
      description: '気軽に楽しめるフレンチビストロ。ワインのセレクションが豊富です。',
      reviewCount: 156,
      distance: 1.8,
      priceRange: '¥¥¥',
      latitude: 35.6586,
      longitude: 139.7016,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _createMapMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _createMapMarkers() {
    _markers = _allRestaurants.map((restaurant) {
      return Marker(
        markerId: MarkerId(restaurant.id),
        position: LatLng(restaurant.latitude, restaurant.longitude),
        infoWindow: InfoWindow(
          title: restaurant.name,
          snippet: '${restaurant.category} • ⭐${restaurant.overallRating}',
        ),
        onTap: () {
          setState(() {
            _selectedMapRestaurant = restaurant;
          });
        },
      );
    }).toSet();
  }

  void _searchRestaurants(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allRestaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
              restaurant.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '店舗を選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(
                  icon: Icon(Icons.search),
                  text: '検索',
                ),
                Tab(
                  icon: Icon(Icons.map),
                  text: 'マップ',
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _searchRestaurants,
            style: const TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: '店舗名またはカテゴリを入力',
              hintStyle: const TextStyle(
                fontFamily: 'NotoSansJP',
                color: Colors.grey,
                fontSize: 16,
              ),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final restaurant = _searchResults[index];
                      return _buildRestaurantListItem(restaurant);
                    },
                  )
                : _isSearching && _searchController.text.isNotEmpty
                    ? const Center(
                        child: Text(
                          '該当する店舗が見つかりませんでした',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          '店舗名またはカテゴリを入力して検索してください',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _allRestaurants.isNotEmpty ? _allRestaurants.first.latitude : 35.6762,
                _allRestaurants.isNotEmpty ? _allRestaurants.first.longitude : 139.6503,
              ),
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
        ),
        if (_selectedMapRestaurant != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildRestaurantListItem(_selectedMapRestaurant!, showSelectButton: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onRestaurantSelected(_selectedMapRestaurant!);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'この店舗を選択',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantListItem(Restaurant restaurant, {bool showSelectButton = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: const Icon(Icons.restaurant, color: Colors.grey),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${restaurant.category} • ${restaurant.priceRange}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              restaurant.address,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(
              restaurant.overallRating.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: showSelectButton ? null : () {
          widget.onRestaurantSelected(restaurant);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}