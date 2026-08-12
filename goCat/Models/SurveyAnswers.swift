import Foundation

/// What the five onboarding questions collect.
///
/// Only `focusSpan` changes a setting — it picks the preselected duration chip
/// on the first-session screen and on Home. The other four flavour copy and
/// nothing else, which the survey admits to on screen 5 ("This sets your
/// default session"). Nothing here identifies anyone: no name, no email, no
/// birth year, and it never leaves the device.
struct SurveyAnswers: Codable, Hashable {
    var source: Source?
    var useCase: UseCase?
    var focusSpan: FocusSpan?
    var hardestPart: HardestPart?
    var timeOfDay: TimeOfDay?

    static let empty = SurveyAnswers()

    /// The bar reflects answers given, not screens seen, so skipping forward
    /// never shows progress the user didn't make.
    var answeredCount: Int {
        [source != nil, useCase != nil, focusSpan != nil, hardestPart != nil, timeOfDay != nil]
            .filter { $0 }.count
    }

    enum Source: String, Codable, CaseIterable {
        case appStore, tikTok, youTube, reddit, friend, other

        var label: String {
            switch self {
            case .appStore: "App Store search"
            case .tikTok: "TikTok or Reels"
            case .youTube: "YouTube"
            case .reddit: "Reddit"
            case .friend: "A friend"
            case .other: "Other"
            }
        }
    }

    enum UseCase: String, Codable, CaseIterable {
        case studying, work, reading, creative, chores, other

        var label: String {
            switch self {
            case .studying: "Studying"
            case .work: "Work"
            case .reading: "Reading"
            case .creative: "Creative work"
            case .chores: "Chores & admin"
            case .other: "Something else"
            }
        }
    }

    /// The only functional answer. Every band maps *down* — someone who loses
    /// whole afternoons still starts at 45 minutes, not two hours, because
    /// over-committing is the classic failure mode this app exists to avoid.
    enum FocusSpan: String, Codable, CaseIterable {
        case under15, fifteenToTwentyFive, twentyFiveToFortyFive, fortyFivePlus

        var label: String {
            switch self {
            case .under15: "Under 15 min"
            case .fifteenToTwentyFive: "15–25 min"
            case .twentyFiveToFortyFive: "25–45 min"
            case .fortyFivePlus: "45 min or more"
            }
        }

        var defaultMinutes: Int {
            switch self {
            case .under15: 15
            case .fifteenToTwentyFive: 25
            case .twentyFiveToFortyFive, .fortyFivePlus: 45
            }
        }
    }

    enum HardestPart: String, Codable, CaseIterable {
        case gettingStarted, stayingWithIt, phoneDistractions, losingTrack

        var label: String {
            switch self {
            case .gettingStarted: "Getting started"
            case .stayingWithIt: "Staying with it"
            case .phoneDistractions: "Phone distractions"
            case .losingTrack: "Losing track of time"
            }
        }

        /// The third summary card names the user's own stated problem back to
        /// them, so the no-pause rule is framed against it rather than asserted.
        var summaryTitle: String {
            switch self {
            case .gettingStarted: "A nudge to begin"
            case .stayingWithIt: "A room you can't leave"
            case .phoneDistractions: "One screen, nothing else"
            case .losingTrack: "A clock you can see"
            }
        }

        var summaryCaption: String {
            switch self {
            case .gettingStarted: "You said starting is the hard part"
            case .stayingWithIt: "You said staying with it is the hard part"
            case .phoneDistractions: "You said your phone gets in the way"
            case .losingTrack: "You said time gets away from you"
            }
        }
    }

    enum TimeOfDay: String, Codable, CaseIterable {
        case morning, afternoon, evening, lateNight

        var label: String {
            switch self {
            case .morning: "Morning"
            case .afternoon: "Afternoon"
            case .evening: "Evening"
            case .lateNight: "Late night"
            }
        }
    }
}
