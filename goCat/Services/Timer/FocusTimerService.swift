import Foundation
import Observation

/// The countdown.
///
/// The time remaining is *always* `endDate - now`. It is never accumulated by
/// subtracting from a counter, because iOS suspends a backgrounded app's tasks:
/// the previous implementation decremented once per `Task.sleep(1s)`, so a
/// 25-minute session that spent time in the background could take an hour of
/// wall clock to finish and the number on screen was fiction.
///
/// The tick exists only to give SwiftUI something to redraw against. If it
/// stalls, drifts, or stops entirely while backgrounded, the displayed time is
/// still correct the moment it resumes.
@MainActor
@Observable
final class FocusTimerService {
    private(set) var state: FocusSessionState = .idle

    /// Moves once per second while running, purely to drive redraws.
    private(set) var referenceDate: Date = .now

    private(set) var endDate: Date?

    var duration: TimeInterval

    /// Fires whenever the session finishes — whether the countdown ran out on
    /// screen or elapsed while the app was away. Lets callers keep a single
    /// source of truth in sync without duplicating the "did it finish" check.
    var onComplete: (@MainActor () -> Void)?

    private var tickTask: Task<Void, Never>?

    init(duration: TimeInterval = 25 * 60) {
        self.duration = duration
    }

    var remainingSeconds: TimeInterval {
        guard let endDate else { return duration }
        return max(0, endDate.timeIntervalSince(referenceDate))
    }

    /// True for the last 60 seconds, when the strip grows its accent hairline.
    var isInFinalMinute: Bool {
        state == .running && remainingSeconds <= 60
    }

    /// 0...1 across the final minute, for the hairline's width.
    var finalMinuteProgress: Double {
        guard isInFinalMinute else { return 0 }
        return (60 - remainingSeconds) / 60
    }

    func start(endingAt end: Date? = nil) {
        guard state != .running else { return }
        endDate = end ?? Date.now.addingTimeInterval(duration)
        referenceDate = .now
        state = .running
        scheduleTicking()
    }

    /// A session the user backed out of early — distinct from `complete()`.
    /// No `onCancel` callback: unlike completion, cancellation only ever
    /// happens from the explicit button tap, so there is no second path that
    /// needs to stay in sync.
    func cancel() {
        stopTicking()
        state = .cancelled
    }

    func complete() {
        stopTicking()
        referenceDate = endDate ?? .now
        state = .completed
        onComplete?()
    }

    func reset(to duration: TimeInterval? = nil) {
        stopTicking()
        if let duration {
            self.duration = duration
        }
        endDate = nil
        referenceDate = .now
        state = .idle
    }

    /// Call when the app returns to the foreground. The clock kept running
    /// while we were away, so the session may already be over.
    func refresh() {
        guard state == .running else { return }
        referenceDate = .now
        if remainingSeconds <= 0 {
            complete()
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }

    private func scheduleTicking() {
        stopTicking()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                guard !Task.isCancelled, let self, self.state == .running else { return }

                self.referenceDate = .now

                if self.remainingSeconds <= 0 {
                    self.complete()
                    return
                }
            }
        }
    }
}
