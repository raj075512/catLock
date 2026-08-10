import XCTest
@testable import goCat

final class OnboardingFlowTests: XCTestCase {

    @MainActor
    func testFlowVisitsEveryStepInOrder() {
        let viewModel = OnboardingViewModel()
        XCTAssertEqual(viewModel.currentStep, .welcome)

        viewModel.advance()
        XCTAssertEqual(viewModel.currentStep, .howItWorks,
                       "How it works must come before anything asks the user to choose")

        viewModel.advance()
        XCTAssertEqual(viewModel.currentStep, .focusGoal)

        viewModel.advance()
        XCTAssertEqual(viewModel.currentStep, .notifications)
    }

    @MainActor
    func testAdvancingPastTheEndIsSafe() {
        let viewModel = OnboardingViewModel()
        for _ in 0..<20 { viewModel.advance() }
        XCTAssertEqual(viewModel.currentStep, .notifications,
                       "Advancing past the last step must not wrap or crash")
    }

    /// Every case must be reachable, or a screen exists that nobody can see.
    @MainActor
    func testEveryStepIsReachableByAdvancing() {
        let viewModel = OnboardingViewModel()
        var seen: Set<OnboardingViewModel.Step> = [viewModel.currentStep]
        for _ in 0..<OnboardingViewModel.Step.allCases.count {
            viewModel.advance()
            seen.insert(viewModel.currentStep)
        }
        XCTAssertEqual(seen.count, OnboardingViewModel.Step.allCases.count)
    }
}
