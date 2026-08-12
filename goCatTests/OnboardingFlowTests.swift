import XCTest
@testable import goCat

@MainActor
final class OnboardingFlowTests: XCTestCase {
    private func makeState() -> AppState {
        let defaults = UserDefaults(suiteName: "OnboardingFlowTests")!
        defaults.removePersistentDomain(forName: "OnboardingFlowTests")
        return AppState(settingsStore: SettingsStore(store: UserDefaultsStore(defaults: defaults)))
    }

    func testFlowRunsSplashToFirstSession() {
        let viewModel = OnboardingViewModel(state: makeState())

        XCTAssertEqual(viewModel.step, .splash)

        viewModel.beginAfterSplash()
        XCTAssertEqual(viewModel.step, .meetTheCat)

        viewModel.getStarted()
        XCTAssertEqual(viewModel.step, .source)

        viewModel.answer(source: .reddit)
        XCTAssertEqual(viewModel.step, .useCase)

        viewModel.answer(useCase: .work)
        XCTAssertEqual(viewModel.step, .focusSpan)

        viewModel.answer(focusSpan: .fifteenToTwentyFive)
        XCTAssertEqual(viewModel.step, .hardestPart)

        viewModel.answer(hardestPart: .gettingStarted)
        XCTAssertEqual(viewModel.step, .timeOfDay)

        viewModel.answer(timeOfDay: .morning)
        XCTAssertEqual(viewModel.step, .summary)

        viewModel.acceptSummary()
        XCTAssertEqual(viewModel.step, .howItWorks)

        viewModel.acknowledgeHowItWorks()
        XCTAssertEqual(viewModel.step, .firstSession)
    }

    /// The bar reflects answers given, not screens seen.
    func testProgressCountsAnswersNotScreens() {
        let viewModel = OnboardingViewModel(state: makeState())

        viewModel.getStarted()
        XCTAssertEqual(viewModel.answeredCount, 0, "Arriving at question 1 is not progress")

        viewModel.answer(source: .friend)
        XCTAssertEqual(viewModel.answeredCount, 1)
    }

    /// A summary of answers nobody gave would be a screen of fiction, so Skip
    /// jumps past it.
    func testSkipGoesStraightToHowItWorks() {
        let viewModel = OnboardingViewModel(state: makeState())

        viewModel.getStarted()
        viewModel.skipSurvey()

        XCTAssertEqual(viewModel.step, .howItWorks)
        XCTAssertEqual(viewModel.firstSessionMinutes, 25, "Skipping defaults to 25 minutes")
    }

    /// Q3 is the only answer with a functional consequence, and every band
    /// maps *down* — over-committing is the failure mode this app avoids.
    func testFocusSpanSetsTheDefaultDurationAndAlwaysMapsDown() {
        XCTAssertEqual(SurveyAnswers.FocusSpan.under15.defaultMinutes, 15)
        XCTAssertEqual(SurveyAnswers.FocusSpan.fifteenToTwentyFive.defaultMinutes, 25)
        XCTAssertEqual(SurveyAnswers.FocusSpan.twentyFiveToFortyFive.defaultMinutes, 45)
        XCTAssertEqual(
            SurveyAnswers.FocusSpan.fortyFivePlus.defaultMinutes,
            45,
            "\"45 min or more\" still starts at 45, never at two hours"
        )
    }

    func testFinishingWritesTheAnswersAndCompletesOnboarding() {
        let state = makeState()
        let viewModel = OnboardingViewModel(state: state)

        viewModel.answer(focusSpan: .under15)
        viewModel.finish(startingMinutes: 15)

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertEqual(state.selectedMinutes, 15)
        XCTAssertEqual(state.surveyAnswers.focusSpan, .under15)
    }

    func testGoingBackReopensThePreviousQuestion() {
        let viewModel = OnboardingViewModel(state: makeState())

        viewModel.getStarted()
        viewModel.answer(source: .youTube)
        viewModel.goBack()

        XCTAssertEqual(viewModel.step, .source)
    }
}
