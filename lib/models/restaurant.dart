import 'package:google_maps_flutter/google_maps_flutter.dart';

class Restaurant {
  final String id;
  final String name;
  final String category;
  final double? overallRating;
  final String address;
  final String phoneNumber;
  final String openingHours;
  final List<String> images;
  final String description;
  final int reviewCount;
  final double distance; // in kilometers
  final String priceRange; // e.g., "¥¥", "¥¥¥"
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    this.overallRating,
    required this.address,
    required this.phoneNumber,
    required this.openingHours,
    required this.images,
    required this.description,
    required this.reviewCount,
    required this.distance,
    required this.priceRange,
    required this.latitude,
    required this.longitude,
  });

  // Googleスプレッドシートからのデータをパースするためのファクトリーコンストラクター
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      overallRating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      openingHours: json['openingHours']?.toString() ?? '',
      images: json['imageUrl'] != null ? [json['imageUrl'].toString()] : [],
      description: json['description']?.toString() ?? '',
      reviewCount: json['reviewCount'] != null ? int.tryParse(json['reviewCount'].toString()) ?? 0 : 0,
      distance: json['distance'] != null ? double.tryParse(json['distance'].toString()) ?? 0.0 : 0.0,
      priceRange: json['priceRange']?.toString() ?? '¥',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) ?? 0.0 : 0.0,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) ?? 0.0 : 0.0,
    );
  }

  // Google Maps用の便利メソッド
  LatLng get position => LatLng(latitude, longitude);

  // マーカー用の情報を取得
  String get markerTitle => name;
  String get markerSnippet => '$category • $priceRange';
}

class Rating {
  final double? overall;
  final double? food;
  final double? service;
  final double? value;

  Rating({
    this.overall,
    this.food,
    this.service,
    this.value,
  });

  bool get hasAnyRating => overall != null || food != null || service != null || value != null;
}