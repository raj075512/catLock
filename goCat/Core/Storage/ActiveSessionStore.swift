import Foundation

/// Remembers a session that is currently running, so force-quitting the app
/// isn't a silent way out of it.
///
/// The handoff left this undefined and warned that silence here becomes a bug
/// report. The decision: **a running session survives force-quit and reboot**,
/// because it already survives backgrounding, and "leaving the app keeps the
/// timer running" has to mean the same thing whether the user swiped up to the
/// Home screen or swiped the app away. Relaunching mid-session drops straight
/// back into it; relaunching after it would have ended shows the completion
/// screen and records it.
///
/// The alternative — discarding it — would make force-quit the one escape
/// hatch the product deliberately doesn't offer.
struct ActiveSession: Codable, Hashable {
    var endDate: Date
    var minutes: Int
    var soundID: SoundOption.ID?
}

final class ActiveSessionStore {
    static let shared = ActiveSessionStore()

    private enum Keys {
        static let activeSession = "activeSession"
    }

    private let store: UserDefaultsStore

    init(store: UserDefaultsStore = .shared) {
        self.store = store
    }

    var activeSession: ActiveSession? {
        store.storedValue(forKey: Keys.activeSession)
    }

    func begin(_ session: ActiveSession) {
        store.set(session, forKey: Keys.activeSession)
    }

    func clear() {
        store.removeValue(forKey: Keys.activeSession)
    }
}
