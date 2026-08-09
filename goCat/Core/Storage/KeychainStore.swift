import Foundation
import Security

/// Secure, encrypted-at-rest storage for anything sensitive: auth/session
/// tokens, RevenueCat/App Store receipt or entitlement caches, backend API
/// keys fetched at runtime, etc.
///
/// `UserDefaults` (see `UserDefaultsStore`) is unencrypted on disk and is
/// fine for plain preferences (selected room, sound, durations), but must
/// never hold secrets or auth material. This wrapper is the designated
/// place for that data going forward — nothing currently stored in the app
/// needs it yet (there is no backend/auth integrated), but it exists so
/// future work has a secure-by-default option instead of reaching for
/// `UserDefaults` out of convenience.
final class KeychainStore {
    static let shared = KeychainStore()

    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.gocat.app") {
        self.service = service
    }

    @discardableResult
    func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return set(data, forKey: key)
    }

    @discardableResult
    func set(_ data: Data, forKey key: String) -> Bool {
        var query = baseQuery(forKey: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            AppLogger.security.error("Keychain write failed for key \(key, privacy: .private): status \(status, privacy: .public)")
        }
        return status == errSecSuccess
    }

    func string(forKey key: String) -> String? {
        guard let data = data(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func data(forKey key: String) -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    @discardableResult
    func removeValue(forKey key: String) -> Bool {
        let query = baseQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
