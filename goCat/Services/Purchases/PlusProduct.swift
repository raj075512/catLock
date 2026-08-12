import Foundation

/// The two catLock Plus products.
///
/// Two tiers, not three. `MONETIZATION.md` at one point described a weekly
/// tier as well; the paywall was drawn for two cards, and its legal disclosure,
/// its 32pt price and its swapping button label were all written against that.
/// A weekly tier at the price that document floated also sits in the band
/// Apple scrutinises hardest, which is a poor trade for a first paid build.
///
/// Identifiers live here and nowhere else. They are permanent once the App
/// Store Connect record exists, and the app's name — and therefore its bundle
/// ID — is still unresolved (`legal/IP_CLEARANCE.md`), so keeping them in one
/// constant makes that rename a one-line change rather than a search.
enum PlusProduct: String, CaseIterable {
    case yearly = "catlock.plus.yearly"
    case monthly = "catlock.plus.monthly"

    static var identifiers: Set<String> {
        Set(allCases.map(\.rawValue))
    }

    /// The paywall preselects yearly. It carries the trial, it is where
    /// lifetime value comes from, and against it the monthly price reads as
    /// the expensive convenience option — which is how it should read.
    static let preselected: PlusProduct = .yearly

    /// Only the yearly tier carries the seven-day trial. The monthly card says
    /// "Billed monthly. No trial." out loud rather than leaving it ambiguous.
    var hasIntroductoryTrial: Bool {
        self == .yearly
    }

    /// Sort order on the paywall — yearly first.
    var displayOrder: Int {
        switch self {
        case .yearly: 0
        case .monthly: 1
        }
    }
}
