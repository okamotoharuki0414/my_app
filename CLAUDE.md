# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application with Firebase integration. The project is a basic Flutter app that demonstrates Firebase connectivity and includes multi-platform support (Android, iOS, macOS, Windows, Web, Linux).

## Development Commands

### Build and Run
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version
- `flutter build macos` - Build macOS app
- `flutter build windows` - Build Windows app

### Testing
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file

### Code Quality
- `flutter analyze` - Run static analysis (uses analysis_options.yaml)
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies
- `flutter pub outdated` - Check for outdated packages

### Firebase
- `flutterfire configure` - Configure Firebase for new platforms
- Firebase is already configured for Android, iOS, macOS, Windows, and Web

### Google Maps
- Google Maps API key configured and working
- API key: AIzaSyARwqfqjYHsQL7gX3ze57vbx24kcuyyY-w (set in AndroidManifest.xml)
- Features implemented:
  - Interactive Google Maps with zoom and pan
  - Custom restaurant markers with selection states
  - Map expansion/contraction via gesture controls
  - Integration with restaurant filtering system
  - Custom price pin overlays on top of Google Maps
  - **CSV Data Integration**: Restaurant data from CSV files with lat/lng coordinates
  - **Multiple Map Screens**: Simple Maps, Shonan-Dai Maps, and CSV-based Maps
  - **Marker Categorization**: Color-coded markers by restaurant category (Italian=Orange, BBQ=Red, etc.)
  - **Area Filtering**: Tokyo Center vs Shonan-Dai area filtering
  - **MapSearchScreen CSV Integration**: Main search screen completely rebuilt using CSV data only
  - **Tokyo Center Exclusion**: Filters out Tokyo metropolitan area stores, showing only Shonan-Dai area (Kanagawa)
  - **LatLngBounds Auto-adjustment**: Camera automatically adjusts to show all CSV markers with proper boundaries
  - **Google Maps Standard Display**: All maps use MapType.normal with buildings, roads, stations, and facility names
  - **Full Google Maps Functionality**: Complete gesture support (zoom, pan, rotate, tilt) identical to Google Maps app
  - **Unrestricted Zoom**: Users can freely zoom with pinch gestures (MinMaxZoomPreference.unbounded)
  - **Facility Name Display**: Buildings and facility names (7-Eleven, Starbucks, etc.) shown via buildingsEnabled and mapToolbarEnabled
  - **UI Simplification**: Removed unnecessary floating action buttons from Timeline screen
  - **Geographic Filtering**: Uses address-based and coordinate-based filtering for precise area selection
- Current status: ✅ Fully functional

## Architecture

### Core Structure
- `lib/main.dart` - Main application entry point with Firebase initialization
- `lib/firebase_options.dart` - Generated Firebase configuration (auto-generated by FlutterFire CLI)
- `test/widget_test.dart` - Widget tests (note: current test is outdated and needs updating)

### Firebase Integration
- Firebase Core is integrated and initialized in main.dart
- Platform-specific Firebase configurations are handled automatically
- Project ID: `reina-0414`
- Firebase configuration files are present for all platforms

### Platform Support
- Android: Full support with google-services.json (minSdk: 23, Updated 2025-07-22)
- iOS: Full support with GoogleService-Info.plist + location permissions
- macOS: Full support with GoogleService-Info.plist
- Windows: Web-based Firebase configuration
- Web: Full support with web configuration
- Linux: Not configured (will throw UnsupportedError)

## Key Files and Configurations

### Analysis Options
- Uses `package:flutter_lints/flutter.yaml` for linting
- Standard Flutter lint rules are applied
- Custom rules can be added in `analysis_options.yaml`

### Dependencies (Updated 2025-07-22)
- `firebase_core: ^3.15.2` - Firebase core functionality (Updated)
- `firebase_auth: ^5.7.0` - Firebase authentication (Updated)
- `cloud_firestore: ^5.6.12` - Cloud Firestore database (Updated)
- `google_maps_flutter: ^2.9.0` - Google Maps integration (Updated)
- `geolocator: ^14.0.2` - Location services (Updated)
- `location: ^8.0.1` - Location plugin (Updated)
- `go_router: ^16.0.0` - Navigation routing (Updated)
- `permission_handler: ^12.0.1` - App permissions (Updated)
- `share_plus: ^11.0.0` - Share functionality (Updated)
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Linting rules (dev dependency)

## Testing Notes

The current widget test in `test/widget_test.dart` is outdated and expects a counter app, but the actual app shows "Firebase Connected!" text. Tests should be updated to match the actual app behavior.

## Development Notes

- The app uses Material Design as the primary design system
- Firebase is initialized asynchronously in main() before runApp()
- The app currently displays a simple "Firebase Connected!" message
- All Firebase API keys are included in the codebase (standard practice for Firebase client apps)