import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  List<Restaurant> _restaurants = [];
  Position? _currentPosition;

  // 東京中央の座標
  static const CameraPosition _tokyoCenter = CameraPosition(
    target: LatLng(35.6762, 139.6503), // 東京駅付近
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _getCurrentLocation();
  }

  Future<void> _loadRestaurants() async {
    try {
      // レストランデータを読み込み
      final restaurants = await RestaurantService.fetchRestaurantsFromSheet();
      setState(() {
        _restaurants = restaurants;
        _createMarkers();
      });
    } catch (e) {
      print('Error loading restaurants: $e');
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    for (Restaurant restaurant in _restaurants) {
      _markers.add(
        Marker(
          markerId: MarkerId(restaurant.id),
          position: restaurant.position,
          infoWindow: InfoWindow(
            title: restaurant.markerTitle,
            snippet: restaurant.markerSnippet,
            onTap: () => _onMarkerTapped(restaurant),
          ),
          onTap: () => _onMarkerTapped(restaurant),
        ),
      );
    }
  }

  void _onMarkerTapped(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.category,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.address,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (restaurant.overallRating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.overallRating!.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 詳細画面への遷移などを実装
                    },
                    child: const Text('詳細を見る'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // 現在地にカメラを移動
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レストラン地図'),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _tokyoCenter,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentPosition != null) {
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          } else {
            _getCurrentLocation();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}