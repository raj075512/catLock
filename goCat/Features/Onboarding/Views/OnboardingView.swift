import SwiftUI

/// Baseline onboarding, screens 1–10.
///
/// Chosen over the two alternatives in the handoff (v2's six screens, v3's
/// dark amber direction). It keeps the locked light design system, so nothing
/// else in the app had to be re-tokenised.
///
/// Rule 6 throughout: no sign-in wall, no name, no email, no birth year.
/// Nothing collected here leaves the phone, and the summary screen says so.
struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        Group {
            switch viewModel.step {
            case .splash:
                SplashPage { viewModel.beginAfterSplash() }

            case .meetTheCat:
                MeetTheCatPage { viewModel.getStarted() }

            case .source:
                SurveyPage(
                    question: "How did you hear about catLock?",
                    options: SurveyAnswers.Source.allCases,
                    label: \.label,
                    answeredCount: viewModel.answeredCount,
                    onBack: viewModel.goBack,
                    onSkip: viewModel.skipSurvey,
                    onSelect: viewModel.answer(source:)
                )

            case .useCase:
                SurveyPage(
                    question: "What will you use it for?",
                    options: SurveyAnswers.UseCase.allCases,
                    label: \.label,
                    answeredCount: viewModel.answeredCount,
                    onBack: viewModel.goBack,
                    onSkip: viewModel.skipSurvey,
                    onSelect: viewModel.answer(useCase:)
                )

            case .focusSpan:
                // The one question with a functional consequence. The caption
                // says so, to keep the survey honest.
                SurveyPage(
                    question: "How long can you usually focus before drifting?",
                    caption: "A guess is fine. This sets your default session.",
                    options: SurveyAnswers.FocusSpan.allCases,
                    label: \.label,
                    answeredCount: viewModel.answeredCount,
                    onBack: viewModel.goBack,
                    onSkip: viewModel.skipSurvey,
                    onSelect: viewModel.answer(focusSpan:)
                )

            case .hardestPart:
                SurveyPage(
                    question: "What's hardest for you?",
                    options: SurveyAnswers.HardestPart.allCases,
                    label: \.label,
                    answeredCount: viewModel.answeredCount,
                    onBack: viewModel.goBack,
                    onSkip: viewModel.skipSurvey,
                    onSelect: viewModel.answer(hardestPart:)
                )

            case .timeOfDay:
                SurveyPage(
                    question: "When do you usually focus?",
                    options: SurveyAnswers.TimeOfDay.allCases,
                    label: \.label,
                    answeredCount: viewModel.answeredCount,
                    onBack: viewModel.goBack,
                    onSkip: viewModel.skipSurvey,
                    onSelect: viewModel.answer(timeOfDay:)
                )

            case .summary:
                SummaryPage(answers: viewModel.answers) { viewModel.acceptSummary() }

            case .howItWorks:
                HowItWorksPage { viewModel.acknowledgeHowItWorks() }

            case .firstSession:
                FirstSessionPage(
                    preselectedMinutes: viewModel.firstSessionMinutes
                ) { minutes in
                    // Home presents the session; this view is about to be
                    // replaced by it.
                    viewModel.finish(startingMinutes: minutes)
                }
            }
        }
        .animation(AppAnimation.standard, value: viewModel.step)
    }
}

#Preview {
    OnboardingView()
}
