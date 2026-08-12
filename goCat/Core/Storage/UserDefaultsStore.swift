import Foundation

final class UserDefaultsStore {
    static let shared = UserDefaultsStore()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func value<T: Decodable>(forKey key: String, fallback: T) -> T {
        guard let data = defaults.data(forKey: key),
              let value = try? decoder.decode(T.self, from: data) else {
            return fallback
        }
        return value
    }

    /// Distinguishes "never written" from "written, and happens to equal the
    /// default" — which a fallback-based read cannot do, and which migrations
    /// need in order to know whether they have already run.
    func storedValue<T: Decodable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
