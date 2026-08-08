import Foundation

#if os(iOS)
import UIKit
#endif

struct AccessibilityManager {
    var prefersReducedMotion: Bool {
#if os(iOS)
        UIAccessibility.isReduceMotionEnabled
#else
        false
#endif
    }
}
