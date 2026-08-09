import Foundation
import os

#if os(iOS)
import UIKit
#endif

/// Baseline runtime hardening, on by default. This is intentionally
/// lightweight and never blocks a legitimate user — it only informs
/// decisions (e.g. whether to trust on-device purchase/entitlement state)
/// and gives us a signal in logs/analytics if a device looks tampered with.
///
/// Scope, on purpose:
/// - No aggressive jailbreak "hard block" — Apple discourages it and it
///   punishes legitimate power users while doing little against a
///   determined attacker. Heuristics here are advisory.
/// - No network calls, no third-party SDKs. Everything runs on-device.
///
/// Complementary practices enforced elsewhere in the codebase:
/// - `KeychainStore` for any secret/entitlement/token data instead of
///   `UserDefaults`, which is unencrypted on disk.
/// - No hardcoded API keys/secrets anywhere in source (see DESIGN.md
///   Security section) — backend/RevenueCat keys, when added, must be
///   injected via build configuration, never committed.
/// - App Transport Security should stay at its default (no arbitrary
///   loads) in the target's Info settings — this app makes no network
///   calls today, so there is nothing to allowlist.
@MainActor
enum AppSecurityManager {
    struct SecurityPosture {
        let isLikelyJailbroken: Bool
        let isDebuggerAttached: Bool

        var isTrustedEnvironment: Bool {
            !isLikelyJailbroken && !isDebuggerAttached
        }
    }

    /// Run once at launch. Logs findings; callers decide what (if anything)
    /// to do with a compromised posture — e.g. a future premium/entitlement
    /// check could treat on-device purchase state as lower-trust and prefer
    /// server-side receipt validation when a backend exists.
    @discardableResult
    static func runLaunchChecks() -> SecurityPosture {
        let posture = SecurityPosture(
            isLikelyJailbroken: isLikelyJailbroken(),
            isDebuggerAttached: isDebuggerAttached()
        )

        if !posture.isTrustedEnvironment {
            AppLogger.security.warning(
                "Untrusted runtime environment detected (jailbreak: \(posture.isLikelyJailbroken, privacy: .public), debugger: \(posture.isDebuggerAttached, privacy: .public))."
            )
        } else {
            AppLogger.security.debug("Runtime environment checks passed.")
        }

        return posture
    }

    // MARK: - Jailbreak heuristics

    private static func isLikelyJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return hasSuspiciousFiles() || canWriteOutsideSandbox() || canOpenCydiaURLScheme()
        #endif
    }

    private static func hasSuspiciousFiles() -> Bool {
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/bin/bash",
            "/etc/apt",
            "/private/var/lib/apt"
        ]
        return suspiciousPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    private static func canWriteOutsideSandbox() -> Bool {
        let testPath = "/private/jailbreak_test_\(UUID().uuidString).txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    private static func canOpenCydiaURLScheme() -> Bool {
        #if os(iOS)
        guard let url = URL(string: "cydia://package/com.example.package") else { return false }
        var canOpen = false
        if Thread.isMainThread {
            canOpen = UIApplication.shared.canOpenURL(url)
        }
        return canOpen
        #else
        return false
        #endif
    }

    // MARK: - Debugger detection

    private static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
