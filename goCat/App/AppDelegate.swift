import Foundation

#if os(iOS)
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppSecurityManager.runLaunchChecks()
        return true
    }
}
#else
final class AppDelegate: NSObject {}
#endif
