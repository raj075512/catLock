import Foundation
import Observation

@MainActor
@Observable
final class RiveAnimationService {
    static let shared = RiveAnimationService()

    private(set) var currentInput: AnimationInput = .idle

    func setInput(_ input: AnimationInput) {
        currentInput = input
    }
}
