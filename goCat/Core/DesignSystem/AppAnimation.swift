import SwiftUI

enum AppAnimation {
    static let quick = Animation.easeOut(duration: 0.18)
    static let standard = Animation.easeInOut(duration: 0.28)
    static let slow = Animation.easeInOut(duration: 0.45)
}
