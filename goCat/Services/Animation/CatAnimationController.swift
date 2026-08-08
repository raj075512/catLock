import Foundation
import Observation

@MainActor
@Observable
final class CatAnimationController {
    private let animationService: RiveAnimationService

    var currentInput: AnimationInput {
        animationService.currentInput
    }

    init(animationService: RiveAnimationService = .shared) {
        self.animationService = animationService
    }

    func update(for sessionState: FocusSessionState) {
        switch sessionState {
        case .idle:
            animationService.setInput(.idle)
        case .running:
            animationService.setInput(.focusing)
        case .paused:
            animationService.setInput(.paused)
        case .completed:
            animationService.setInput(.completed)
        case .cancelled:
            animationService.setInput(.sleeping)
        }
    }
}
