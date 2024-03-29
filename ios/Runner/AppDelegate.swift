import UIKit
import CoreMotion
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let motionManager = CMMotionManager()
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
