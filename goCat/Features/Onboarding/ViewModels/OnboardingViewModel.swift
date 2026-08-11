import Foundation
import Observation

/// Drives the baseline onboarding, screens 1–10.
///
/// Two things are load-bearing here. The progress bar reflects **answers
/// given, not screens seen**, so skipping forward never shows progress the
/// user didn't make. And Skip jumps straight past the summary to "How it
/// works" with 25 minutes as the default — a summary of answers nobody gave
/// would be a screen of fiction.
@MainActor
@Observable
final class OnboardingViewModel {
    enum Step: Hashable {
        case splash
        case meetTheCat
        case source
        case useCase
        case focusSpan
        case hardestPart
        case timeOfDay
        case summary
        case howItWorks
        case firstSession
    }

    /// The five survey screens, in order, for back-navigation and the bar.
    static let surveySteps: [Step] = [.source, .useCase, .focusSpan, .hardestPart, .timeOfDay]

    private(set) var step: Step = .splash
    private(set) var answers = SurveyAnswers()

    /// Set when the user skips, so the summary is skipped too.
    private(set) var didSkipSurvey = false

    private let state: AppState

    init(state: AppState = .shared) {
        self.state = state
    }

    var answeredCount: Int { answers.answeredCount }

    /// The duration the first-session screen preselects. Follows Q3, or 25 by
    /// default — the same number Skip lands on.
    var firstSessionMinutes: Int {
        answers.focusSpan?.defaultMinutes ?? 25
    }

    // MARK: - Navigation

    func beginAfterSplash() {
        guard step == .splash else { return }
        step = .meetTheCat
    }

    func getStarted() { step = .source }

    func skipSurvey() {
        didSkipSurvey = true
        step = .howItWorks
    }

    func goBack() {
        guard let index = Self.surveySteps.firstIndex(of: step) else {
            if step == .summary { step = .timeOfDay }
            else if step == .howItWorks { step = didSkipSurvey ? .source : .summary }
            return
        }
        step = index == 0 ? .meetTheCat : Self.surveySteps[index - 1]
    }

    // MARK: - Answers
    //
    // Selection advances on its own after a short tint — there is no Continue
    // button on any survey screen.

    func answer(source: SurveyAnswers.Source) {
        answers.source = source
        step = .useCase
    }

    func answer(useCase: SurveyAnswers.UseCase) {
        answers.useCase = useCase
        step = .focusSpan
    }

    func answer(focusSpan: SurveyAnswers.FocusSpan) {
        answers.focusSpan = focusSpan
        step = .hardestPart
    }

    func answer(hardestPart: SurveyAnswers.HardestPart) {
        answers.hardestPart = hardestPart
        step = .timeOfDay
    }

    func answer(timeOfDay: SurveyAnswers.TimeOfDay) {
        answers.timeOfDay = timeOfDay
        step = .summary
    }

    func acceptSummary() { step = .howItWorks }

    func acknowledgeHowItWorks() { step = .firstSession }

    /// Ends onboarding inside the product: the next thing on screen is a real
    /// session, not a tour.
    func finish(startingMinutes: Int) {
        var finalAnswers = answers
        if finalAnswers.focusSpan == nil {
            finalAnswers.focusSpan = .fifteenToTwentyFive
        }
        state.selectPreset(startingMinutes)
        // Hand the session to Home to present — see `pendingFirstSessionMinutes`.
        state.pendingFirstSessionMinutes = startingMinutes
        state.completeOnboarding(answers: finalAnswers)
    }
}
