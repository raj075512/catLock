import Foundation
import Observation

/// Owns what Home is *presenting*. The user's actual choices — duration,
/// sound, room — live in `AppState`, because the session screen and the sheets
/// need them too and Home is not their owner.
@MainActor
@Observable
final class HomeViewModel {
    /// The three fixed presets. Custom is handled separately: it needs a
    /// picker sheet, not just another number in this array.
    static let durationPresets = [15, 25, 45]

    enum Sheet: String, Identifiable {
        case sounds, room, tasks, progress, settings, customDuration
        var id: String { rawValue }
    }

    var presentedSheet: Sheet?
    var isSessionActive = false

    /// Set when a session is restored after a force-quit or reboot, so the
    /// session screen picks up the original end date instead of starting a
    /// fresh countdown.
    var restoredSession: ActiveSession?

    private let state: AppState
    private let streakStore: StreakStore
    private let activeSessionStore: ActiveSessionStore

    init(
        state: AppState = .shared,
        streakStore: StreakStore = .shared,
        activeSessionStore: ActiveSessionStore = .shared
    ) {
        self.state = state
        self.streakStore = streakStore
        self.activeSessionStore = activeSessionStore
    }

    var currentStreak: Int { streakStore.currentStreak }
    var hasEverCompleted: Bool { streakStore.hasEverCompleted }
    var selectedMinutes: Int { state.selectedMinutes }
    var isCustomSelected: Bool { state.isCustomSelected }
    var selectedRoom: RoomOption { state.selectedRoom }

    /// The fourth chip. Reads "Custom" until a value has been set, then holds
    /// that value permanently — tapping 15/25/45 deselects it but never
    /// forgets it.
    var customChipTitle: String {
        guard let minutes = state.customMinutes else { return "Custom" }
        let hours = minutes / 60
        let remainder = minutes % 60
        switch (hours, remainder) {
        case (0, let m): return "\(m) min"
        case (let h, 0): return "\(h)h"
        case (let h, let m): return "\(h)h \(m)m"
        }
    }

    /// The custom chip needs more room than a two-digit number. 1.9× once it
    /// holds a value like "1h 20m", 1.3× while it just says "Custom".
    var customChipFlex: CGFloat {
        state.customMinutes == nil ? 1.3 : 1.9
    }

    func selectPreset(_ minutes: Int) {
        state.selectPreset(minutes)
        HapticManager.shared.selection()
    }

    func startSession() {
        HapticManager.shared.impact()
        restoredSession = nil
        isSessionActive = true
    }

    /// Called when Home appears.
    ///
    /// Two ways a session can already be under way: onboarding just handed one
    /// over, or one was running when the app went away. A session that was
    /// running is still running — see `ActiveSessionStore` for why force-quit
    /// doesn't count as an exit.
    func resumeSessionIfNeeded() {
        if let minutes = state.pendingFirstSessionMinutes {
            state.pendingFirstSessionMinutes = nil
            restoredSession = nil
            state.selectPreset(minutes)
            isSessionActive = true
            return
        }

        guard let stored = activeSessionStore.activeSession else { return }
        restoredSession = stored
        isSessionActive = true
    }
}
