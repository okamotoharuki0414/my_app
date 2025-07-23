import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// 湘南台駅中心のGoogle Maps実装
/// 地図の背景表示問題を解決した確実な実装
class ShonanDaiMapsScreen extends StatefulWidget {
  const ShonanDaiMapsScreen({Key? key}) : super(key: key);

  @override
  State<ShonanDaiMapsScreen> createState() => _ShonanDaiMapsScreenState();
}

class _ShonanDaiMapsScreenState extends State<ShonanDaiMapsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  
  // 湘南台駅の正確な座標
  static const LatLng _shonanDaiStation = LatLng(35.341065, 139.486895);
  
  // 初期カメラ位置（湘南台駅中心）
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _shonanDaiStation,
    zoom: 16.0, // 駅周辺がよく見えるズームレベル
  );

  Set<Marker> _markers = {};
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// マップ初期化
  void _initializeMap() {
    developer.log('🗺️ Google Maps初期化開始...');
    
    // 湘南台駅にマーカーを追加
    _markers.add(
      const Marker(
        markerId: MarkerId('shonan_dai_station'),
        position: _shonanDaiStation,
        infoWindow: InfoWindow(
          title: '湘南台駅',
          snippet: '小田急江ノ島線・相鉄いずみ野線・横浜市営地下鉄ブルーライン',
        ),
      ),
    );

    developer.log('✅ マーカー追加完了: ${_markers.length}個');
  }

  /// Google Mapが作成されたときのコールバック
  void _onMapCreated(GoogleMapController controller) async {
    developer.log('📍 Google Map作成開始...');
    
    try {
      _mapController = controller;
      _controller.complete(controller);
      
      // マップスタイルを設定（デバッグ用）
      await _configureMapStyle(controller);
      
      setState(() {
        _mapReady = true;
      });
      
      developer.log('✅ Google Map作成完了');
      developer.log('🎯 初期位置: ${_initialCameraPosition.target}');
      developer.log('🔍 ズームレベル: ${_initialCameraPosition.zoom}');
      
    } catch (e) {
      developer.log('❌ Google Map作成エラー: $e');
    }
  }

  /// マップスタイルを設定
  Future<void> _configureMapStyle(GoogleMapController controller) async {
    try {
      // デバッグ用：マップが正常に動作することを確認
      final LatLngBounds bounds = await controller.getVisibleRegion();
      developer.log('🗺️ 表示範囲: ${bounds.northeast} - ${bounds.southwest}');
    } catch (e) {
      developer.log('⚠️ マップ設定警告: $e');
    }
  }

  /// カメラ移動時のコールバック
  void _onCameraMove(CameraPosition position) {
    developer.log('📹 カメラ移動: ${position.target}, ズーム: ${position.zoom}');
  }

  /// カメラ停止時のコールバック
  void _onCameraIdle() {
    developer.log('📹 カメラ停止');
  }

  /// 湘南台駅に戻る
  Future<void> _goToShonanDai() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
      developer.log('🚶 湘南台駅に移動');
    }
  }

  /// 現在地を取得
  Future<void> _getCurrentLocation() async {
    try {
      developer.log('📍 現在地取得開始...');
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        developer.log('❌ 位置情報権限が拒否されました');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      final LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      }
      
      developer.log('✅ 現在地取得完了: $currentLatLng');
    } catch (e) {
      developer.log('❌ 現在地取得エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('湘南台駅 - Google Maps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // マップステータス表示
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _mapReady ? Icons.check_circle : Icons.hourglass_empty,
              color: _mapReady ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map（画面全体に表示）
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              // Googleマップ標準表示設定（必須要件）
              mapType: MapType.normal, // Googleマップ標準表示（建物・道・駅・施設名含む）
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              
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
          
          // ローディングインジケーター
          if (!_mapReady)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Google Maps読み込み中...'),
                    ],
                  ),
                ),
              ),
            ),
          
          // デバッグ情報表示
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'デバッグ情報',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('中心: 湘南台駅'),
                    Text('座標: ${_shonanDaiStation.latitude.toStringAsFixed(6)}, ${_shonanDaiStation.longitude.toStringAsFixed(6)}'),
                    Text('マーカー: ${_markers.length}個'),
                    Text('ステータス: ${_mapReady ? "準備完了" : "読み込み中"}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 現在地ボタン
          FloatingActionButton(
            heroTag: "location",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          
          // 湘南台駅に戻るボタン
          FloatingActionButton(
            heroTag: "shonan_dai",
            backgroundColor: Colors.blue,
            onPressed: _goToShonanDai,
            child: const Icon(Icons.train, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.blue[50],
        child: const Text(
          '湘南台駅: 小田急江ノ島線・相鉄いずみ野線・横浜市営地下鉄ブルーライン',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}