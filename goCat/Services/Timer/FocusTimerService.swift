import Foundation
import Observation

@MainActor
@Observable
final class FocusTimerService {
    private(set) var state: FocusSessionState = .idle
    private(set) var remainingSeconds: TimeInterval

    var duration: TimeInterval

    /// Fires whenever `complete()` runs — whether from an explicit call or
    /// because the countdown reached zero on its own. Lets callers keep a
    /// single source of truth (e.g. `FocusSession.state`) in sync without
    /// duplicating the "did it finish" check in two places.
    var onComplete: (() -> Void)?

    /// Drives the actual countdown. A plain `while` loop on a `Task` rather
    /// than a `Timer`/`Combine` publisher, so it's cancellable with no
    /// run-loop/target-action bookkeeping.
    private var tickTask: Task<Void, Never>?

    init(duration: TimeInterval = 25 * 60) {
        self.duration = duration
        self.remainingSeconds = duration
    }

    func start() {
        guard state != .running else { return }
        state = .running
        scheduleTicking()
    }

    func pause() {
        state = .paused
        tickTask?.cancel()
        tickTask = nil
    }

    func complete() {
        tickTask?.cancel()
        tickTask = nil
        remainingSeconds = 0
        state = .completed
        onComplete?()
    }

    func reset(to duration: TimeInterval? = nil) {
        tickTask?.cancel()
        tickTask = nil
        if let duration {
            self.duration = duration
        }
        remainingSeconds = self.duration
        state = .idle
    }

    private func scheduleTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while let self, self.state == .running, self.remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard let self, self.state == .running else { return }

                self.remainingSeconds = max(0, self.remainingSeconds - 1)
                if self.remainingSeconds == 0 {
                    self.complete()
                }
            }
        }
    }
}
