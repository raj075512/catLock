import XCTest
@testable import goCat

/// Pins the two properties that make the backend seam worth having: the
/// shipping default does nothing, and a different provider can be dropped in
/// without feature code changing.
@MainActor
final class BackendSeamTests: XCTestCase {

    // MARK: - The default is inert

    func testTheShippingBackendReportsNoAccountIsAvailable() {
        let backend = LocalOnlyBackend()

        XCTAssertEqual(
            backend.identityState,
            .unavailable,
            "Not .signedOut — that would imply an account exists to sign in to"
        )
    }

    func testTheShippingBackendNeverClaimsToHaveSynced() async {
        let backend = LocalOnlyBackend()

        XCTAssertNil(backend.lastSyncedAt)

        let outcome = await backend.sync(
            sessions: [SyncableSession(id: UUID(), minutes: 25, soundName: "Rain", endedAt: .now)],
            tasks: [SyncableTask(id: UUID(), title: "Draft the intro", isCompleted: false, createdAt: .now, completedAt: nil)]
        )

        XCTAssertEqual(
            outcome,
            .notConfigured,
            "Nothing went wrong — there is nowhere to sync to, and that is not an error"
        )
        XCTAssertNil(backend.lastSyncedAt, "A no-op must not move the sync clock")
    }

    func testRefreshAndSignOutAreSafeToCallOnTheDefault() async {
        let backend = LocalOnlyBackend()

        await backend.refreshIdentity()
        await backend.signOut()

        XCTAssertEqual(backend.identityState, .unavailable)
    }

    func testTheAppShipsWithNoBackendConfigured() {
        XCTAssertTrue(
            BackendProvider.current is LocalOnlyBackend,
            "The default must stay local-only until a backend is deliberately adopted"
        )
    }

    // MARK: - A provider can be substituted

    /// Stands in for a future AWS or Supabase implementation. That it conforms
    /// at all is the assertion: the protocols are satisfiable by something
    /// that really does hold an account and really does sync.
    @MainActor
    private final class FakeBackend: Backend {
        var identityState: BackendIdentityState
        private(set) var lastSyncedAt: Date?
        private(set) var syncedSessionCount = 0
        private(set) var didSignOut = false

        init(identityState: BackendIdentityState) {
            self.identityState = identityState
        }

        func refreshIdentity() async {}

        func signOut() async {
            didSignOut = true
            identityState = .signedOut
        }

        func sync(sessions: [SyncableSession], tasks: [SyncableTask]) async -> SyncOutcome {
            syncedSessionCount = sessions.count
            let now = Date.now
            lastSyncedAt = now
            return .synced(at: now)
        }
    }

    func testAnyConformingProviderSlotsInWithoutChangingCallers() async {
        let account = BackendAccount(id: "u_1", email: "ashu@example.com", signedInAt: .now)
        let backend: Backend = FakeBackend(identityState: .signedIn(account))

        // Exactly how feature code would use it — through the protocol, with
        // no idea which vendor is behind it.
        XCTAssertEqual(backend.identityState, .signedIn(account))

        let outcome = await backend.sync(
            sessions: [SyncableSession(id: UUID(), minutes: 45, soundName: nil, endedAt: .now)],
            tasks: []
        )

        guard case .synced = outcome else {
            return XCTFail("Expected a real provider to report a successful sync, got \(outcome)")
        }
        XCTAssertNotNil(backend.lastSyncedAt)
    }

    /// Signing out is not deleting. A provider that clears local data on sign
    /// out would break the promise the account screen makes.
    func testSigningOutChangesIdentityOnly() async {
        let backend = FakeBackend(
            identityState: .signedIn(BackendAccount(id: "u_1", email: nil, signedInAt: .now))
        )

        await backend.signOut()

        XCTAssertTrue(backend.didSignOut)
        XCTAssertEqual(backend.identityState, .signedOut)
        XCTAssertEqual(backend.syncedSessionCount, 0, "Sign out must not trigger a sync")
    }

    /// Expired and signed-out are different states because they say very
    /// different things to a user, and only one of them is alarming.
    func testExpiredIsDistinctFromSignedOut() {
        XCTAssertNotEqual(BackendIdentityState.expired(email: "a@b.com"), .signedOut)
        XCTAssertNotEqual(BackendIdentityState.expired(email: nil), .signedOut)
    }
}
