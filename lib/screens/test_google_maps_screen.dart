import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

/// Google Maps标准显示测试画面
/// 最小限の設定で確実にGoogle標準地図を表示する
class TestGoogleMapsScreen extends StatefulWidget {
  const TestGoogleMapsScreen({super.key});

  @override
  State<TestGoogleMapsScreen> createState() => _TestGoogleMapsScreenState();
}

class _TestGoogleMapsScreenState extends State<TestGoogleMapsScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // 湘南台駅の位置（CSVデータの中心）
  static const LatLng _shonanDaiStation = LatLng(35.341065, 139.486895);

  // 初期カメラ位置
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _shonanDaiStation,
    zoom: 15.0, // デフォルトズームレベル
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps 標準表示テスト'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        // 【絶対確実】Google Maps標準表示
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          print('✅ テスト用Google Maps初期化完了');
        },
        
        // 最小限必要な設定のみ
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true, 
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        
        // Google Maps標準機能
        buildingsEnabled: true,
        indoorViewEnabled: true,
        mapToolbarEnabled: true,
        liteModeEnabled: false, // 重要: ライトモード無効
        
        myLocationEnabled: false, // 位置権限の問題を回避
        myLocationButtonEnabled: false,
        
        zoomControlsEnabled: false,
        compassEnabled: true,
        trafficEnabled: false,
        
        minMaxZoomPreference: MinMaxZoomPreference.unbounded,
        cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    );
  }
}