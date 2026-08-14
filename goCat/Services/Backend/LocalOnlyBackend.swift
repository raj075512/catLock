import Foundation

/// The backend the app ships with: none.
///
/// Every operation is a no-op that reports `.unavailable` / `.notConfigured`.
/// It opens no socket, imports no SDK, and stores nothing — which is what lets
/// `legal/PRIVACY_POLICY.md` keep saying the app makes no network requests and
/// collects no data.
///
/// It is not a stub awaiting replacement. It is the correct implementation for
/// a local-first app, and it stays the default until there is a concrete
/// reason to sync — at which point it also remains the honest fallback for a
/// build with no backend configured.
///
/// Its second job is to keep the seam exercised. A protocol with no conforming
/// type rots quietly; this one is on the live path, so if the boundary stops
/// compiling, the app stops compiling.
@MainActor
final class LocalOnlyBackend: Backend {

    // MARK: - Identity

    /// Always. There is no account to be signed in to, and `.signedOut` would
    /// imply one is available — which is what makes Settings show a sign-in
    /// affordance that goes nowhere.
    let identityState: BackendIdentityState = .unavailable

    func refreshIdentity() async {
        // Nothing to refresh. Deliberately not even a log line: this runs on
        // every launch and every foreground, and noise in the launch path is
        // how a quiet app stops being quiet.
    }

    func signOut() async {
        // Nothing to sign out of. Notably this does *not* touch local data —
        // the same guarantee a real provider has to make.
    }

    // MARK: - Sync

    let lastSyncedAt: Date? = nil

    func sync(sessions: [SyncableSession], tasks: [SyncableTask]) async -> SyncOutcome {
        // Not `.failed`. Nothing went wrong — there is simply nowhere to sync
        // to, and the UI should say nothing rather than show an error for a
        // feature the user never asked for.
        .notConfigured
    }
}
