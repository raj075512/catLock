import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable {
        case welcome
        /// Sets the no-pause expectation before the user can hit it.
        case howItWorks
        case focusGoal
        case notifications
    }

    var currentStep: Step = .welcome

    func advance() {
        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else {
            return
        }
        currentStep = nextStep
    }
}
