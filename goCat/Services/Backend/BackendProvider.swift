import Foundation

/// The seam a backend plugs into — and the reason there isn't one today.
///
/// catLock is local-first and currently collects nothing: no account, no
/// network call, no vendor SDK. That is a feature (`legal/PRIVACY_POLICY.md`
/// declares "Data Not Collected") and it is worth keeping true for as long as
/// possible.
///
/// But "no backend yet" and "no backend ever" are different, and the expensive
/// mistake is letting a vendor's types leak into feature code — a `Supabase`
/// import in a view model, an `AWSCognito` type in `AppState` — because then
/// switching provider means rewriting the app rather than one file.
///
/// So the boundary exists now, while it costs nothing:
///
/// - Feature code talks to `IdentityProviding` and `SyncProviding`, never to a
///   vendor. Nothing in `Features/` imports a networking library.
/// - The types crossing this boundary are plain Swift values defined here.
///   No `Session`, no `AuthUser`, no `AWSCredentials`.
/// - Adding AWS or Supabase means adding *one* conforming type and changing
///   *one* line in `BackendProvider.current`. Nothing else moves.
///
/// Today `current` is `LocalOnlyBackend`, which does nothing and reaches
/// nowhere. The seam is exercised rather than theoretical: the app already
/// runs through it.
enum BackendProvider {
    /// The single place a backend is chosen.
    ///
    /// To adopt AWS: add `AWSBackend` conforming to the two protocols below and
    /// return it here. To adopt Supabase: same, with `SupabaseBackend`. To go
    /// back to local-only: return `LocalOnlyBackend()` again. Feature code is
    /// untouched in all three directions, which is the whole point.
    static let current: Backend = LocalOnlyBackend()
}

/// What a backend must supply. Split in two because the halves are genuinely
/// independent: a provider could offer sync with no accounts (CloudKit), or
/// identity with no sync.
typealias Backend = IdentityProviding & SyncProviding

// MARK: - Identity

/// Who the user is, if anyone.
///
/// Deliberately minimal. The app needs an identifier to scope synced rows and
/// an address to show on an account screen — nothing else. No display name, no
/// avatar, no locale, no last-seen: fields that exist get populated, and
/// fields that get populated end up in a privacy label.
struct BackendAccount: Equatable, Sendable {
    let id: String
    /// May be an Apple private-relay address, which forwards to the real inbox
    /// and hides it from us. Shown to the user as-is, with an explanation.
    let email: String?
    let signedInAt: Date
}

/// The identity states the UI has to render. Kept as an enum rather than a
/// pair of booleans so "signed out" and "session expired" cannot be confused —
/// they say very different things to a user, and only one of them is alarming.
enum BackendIdentityState: Equatable, Sendable {
    /// No backend is configured. The app is local-only and complete.
    case unavailable
    case signedOut
    case signedIn(BackendAccount)
    /// Had a session; it no longer refreshes. Local data is untouched, and the
    /// UI must say so before it says anything else.
    case expired(email: String?)
}

@MainActor
protocol IdentityProviding: AnyObject, Sendable {
    var identityState: BackendIdentityState { get }

    /// Re-read identity from wherever it lives. Must be safe to call on every
    /// launch and every foreground, and must never block the UI.
    func refreshIdentity() async

    /// Ends the session. Must leave local data alone — signing out is not
    /// deleting, and the two are never conflated.
    func signOut() async
}

// MARK: - Sync

/// A record the app would sync. Mirrors the local SwiftData models without
/// depending on them, so a provider implementation never imports SwiftData and
/// the storage layer can change without touching the backend layer.
struct SyncableSession: Equatable, Sendable {
    /// Generated on device, so a session recorded offline keeps its identity
    /// when it eventually syncs rather than arriving as a duplicate.
    let id: UUID
    let minutes: Int
    let soundName: String?
    let endedAt: Date
}

struct SyncableTask: Equatable, Sendable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let createdAt: Date
    let completedAt: Date?
}

enum SyncOutcome: Equatable, Sendable {
    case synced(at: Date)
    /// Nothing to do — no account, or no backend configured.
    case notConfigured
    /// A plain sentence for the user. Never an error code, never a dialog.
    case failed(String)
}

@MainActor
protocol SyncProviding: AnyObject, Sendable {
    var lastSyncedAt: Date? { get }

    func sync(sessions: [SyncableSession], tasks: [SyncableTask]) async -> SyncOutcome
}
