import Foundation
import Observation

@MainActor
@Observable
final class LaunchViewModel {
    private(set) var isReady = false

    func prepare() async {
        isReady = true
    }
}
