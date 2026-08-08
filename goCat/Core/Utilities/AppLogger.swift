import OSLog

enum AppLogger {
    static let app = Logger(subsystem: "goCat", category: "App")
    static let audio = Logger(subsystem: "goCat", category: "Audio")
    static let timer = Logger(subsystem: "goCat", category: "Timer")
    static let purchases = Logger(subsystem: "goCat", category: "Purchases")
}
