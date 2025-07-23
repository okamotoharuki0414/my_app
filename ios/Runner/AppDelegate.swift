import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Info.plistからAPIキーを読み込む
    if let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      GMSServices.provideAPIKey(googleMapsApiKey)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
